/*This file extends the MOOSE framework and applies the Crystal plasticity model
  of Furstoss et al., 2021 for olivine
*/

#include "CrystalPlasticityOlivineUpdate.h"

registerMooseObject("CreepApp", CrystalPlasticityOlivineUpdate);

InputParameters
CrystalPlasticityOlivineUpdate::validParams()
{
  InputParameters params = CrystalPlasticityStressUpdateBase::validParams();
  params.addClassDescription("An implementation of the crystal plasticity model of "
                             "Furstoss et al., 2021 for olivine ");

  // I think these two lines cancel each other but may be required for the
  // base crystal plasticity class
  params.set<MooseEnum>("crystal_lattice_type") = "HCP";
  params.suppressParameter<MooseEnum>("crystal_lattice_type");

  params.addRequiredRangeCheckedParam<Real>("initial_dislocation_density",
                                            "initial_dislocation_desnity>0",
                                            "The initial dislocation density, in 1/mm^2, assumed "
                                            "to be evenly split among slip systems.");

  params.addParam<unsigned int>(
      "slip_system_modes", 1, "Number of slip systems with unique burgers vectors.");

  params.addParam<std::vector<unsigned int>>(
      "number_slip_systems_per_mode",
      std::vector<unsigned int>(), // default
      "The number of slip systems for each mode. The sum of the entries should equal "
      "the total number of slip systems.");

  params.addParam<std::vector<Real>>(
      "tau_c_0",
      std::vector<Real>(),
      "Value of the lattice friction for each slip system mode, unique for "
      "each burgers vector.");

  params.addParam<std::vector<Real>>(
      "burgers_vectors",
      std::vector<Real>(),
      "Value of the burgers vector for each slip system mode, units of mm, "
      "the order must correspond with slip system modes.");

  // Params for dislocation evolution -- hardening / softening

  params.addParam<Real>("taylor_coefficient",
                        1.1,
                        "The taylor coefficient for use in the Taylor equation "
                        "(Taylor, 1934).");

  params.addParam<Real>("shear_modulus", 82.0, "Shear modulus for olivine.");

  params.addParam<Real>("K_1",
                        5.6e8,
                        "The hardening parameter for the dislocation "
                        "density evolution equation. "
                        "Following the Yoshie-Lassraoui-Jonas law, "
                        "(Laasraoui & Jonas, 1991). "
                        "Units in mm^-2");

  params.addParam<Real>("K_2",
                        35.0,
                        "The softening parameter for the dislocation "
                        "density evolution equation. "
                        "Following the Yoshie-Lassraoui-Jonas law, "
                        "(Laasraoui & Jonas, 1991).");

  // Slip strain rate power law parameters

  params.addParam<Real>("reference_slip_rate",
                        5.0e-3,
                        "The reference slip rate used in the "
                        "power-law flow rule. in units 1/s");

  params.addParam<Real>("rate_sensitivity_exponent",
                        0.1,
                        "The rate sensitivity exponents used "
                        "in the power-law flow rule.");

  return params;
}

CrystalPlasticityOlivineUpdate::CrystalPlasticityOlivineUpdate(const InputParameters & parameters)
  : CrystalPlasticityStressUpdateBase(parameters),

    _dislocation_density(declareProperty<std::vector<Real>>(_base_name + "dislocation_density")),

    _dislocation_density_old(
        getMaterialPropertyOld<std::vector<Real>>(_base_name + "dislocation density")),

    _dislocation_increment(
        declareProperty<std::vector<Real>>(_base_name + "dislocation_increment")),

    _dislocations_removed_increment(
        declareProperty<std::vector<Real>>(_base_name + "dislocations_removed_increment")),

    _initial_dislocation_density(getParam<Real>("initial_dislocation_density")),

    _slip_system_modes(getParam<unsigned int>("slip_system_modes")),

    _number_slip_systems_per_mode(
        getParam<std::vector<unsigned int>>("number_slip_systems_per_mode")),

    _tau_c_0(getParam<std::vector<Real>>("tau_c_0")),

    _reference_slip_rate(getParam<Real>("reference_slip_rate")),

    _rate_sensitivity_exponent(getParam<Real>("rate_sensitivity_exponent")),

    _burgers_vectors(getParam<std::vector<Real>>("burgers_vectors")),

    _taylor_coefficient(getParam<Real>("taylor_coefficient")),

    _shear_modulus(getParam<Real>("shear_modulus")),

    _K_1(getParam<Real>("K_1")),

    _K_2(getParam<Real>("K_2"))

{
  // resize local caching vectors used for substepping
  _previous_substep_slip_resistance.resize(_number_slip_systems);
  _previous_substep_dislocation_density.resize(_number_slip_systems);
  _slip_resistance_before_update.resize(_number_slip_systems);
  _dislocations_before_update.resize(_number_slip_systems);

  // check that the number of slip systems is equal to the sum of the types of slip system
  if (_number_slip_systems_per_mode.size() != _slip_system_modes)
    paramError("number_slip_systems_per_mode",
               "The size the number of slip systems per mode is not equal to the number of slip "
               "system types.");

  if (_burgers_vectors.size() != _slip_system_modes)
    paramError("burgers_vectors",
               "Please ensure that the size of burgers_vectors equals the value supplied "
               "for slip_system_modes");

  if (_tau_c_0.size() != _slip_system_modes)
    paramError("tau_c_0",
               "Please ensure that the size of tau_c_0 equals the value supplied "
               "for slip_system_modes");

  unsigned int sum = 0;

  for (const auto i : make_range(_slip_system_modes))
    sum += _number_slip_systems_per_mode[i];
  if (sum != _number_slip_systems)
    paramError("slip_system_modes",
               "The number of slip systems and the sum of the slip systems in each of the slip "
               "system modes are not equal");
}

//// EDIT FROM HERE!!!!!!! /////

void
CrystalPlasticityOlivineUpdate::initQpStatefulProperties()
{
  CrystalPlasticityStressUpdateBase::initQpStatefulProperties();

  // Resize constitutive-model specific material properties
  _dislocation_density[_qp].resize(_number_slip_systems);

  // Set constitutive-model specific initial values from parameters
  const Real _dislocation_density_per_system = _initial_dislocation_density / _number_slip_systems;
  for (const auto i : make_range(_number_slip_systems))
  {
    _dislocation_density[_qp][i] = _dislocation_density_per_system;
    _dislocation_increment[_qp][i] = 0.0;
    _slip_increment[_qp][i] = 0.0;
  }

  // Set initial resistance from lattice friction, which is type dependent
  DenseVector<Real> lattice_resistance(_number_slip_systems, 0.0);
  unsigned int slip_mode = 0;
  unsigned int counter_adjustment = 0;
  for (const auto i : make_range(_number_slip_systems))
  {
    if ((i - counter_adjustment) < _number_slip_systems_per_mode[slip_mode])
      lattice_resistance(i) = _tau_c_0[slip_mode];
    else
    {
      counter_adjustment += _number_slip_systems_per_mode[slip_mode];
      ++slip_mode;
      lattice_resistance(i) = _tau_c_0[slip_mode];
    }
  }

  for (const auto i : make_range(_number_slip_systems))
    _slip_resistance[_qp][i] = lattice_resistance(i);
}

void
CrystalPlasticityOlivineUpdate::setMaterialVectorSize()
{
  CrystalPlasticityStressUpdateBase::setMaterialVectorSize();

  // Resize non-stateful material properties
  _dislocation_increment[_qp].resize(_number_slip_systems);
  _dislocations_removed_increment[_qp].resize(_number_slip_systems);
}

void
CrystalPlasticityOlivineUpdate::setInitialConstitutiveVariableValues()
{
  _slip_resistance[_qp] = _slip_resistance_old[_qp];
  _previous_substep_slip_resistance = _slip_resistance_old[_qp];

  _dislocation_density[_qp] = _dislocation_density_old[_qp];
  _previous_substep_dislocation_density = _dislocation_density_old[_qp];
}

void
CrystalPlasticityOlivineUpdate::setSubstepConstitutiveVariableValues()
{
  _slip_resistance[_qp] = _previous_substep_slip_resistance;
  _dislocation_density[_qp] = _previous_substep_dislocation_density;
}

bool
CrystalPlasticityOlivineUpdate::calculateSlipRate()
{
  for (const auto i : make_range(_number_slip_systems))
  {
    Real driving_force = std::abs(_tau[_qp][i] / _slip_resistance[_qp][i]);
    if (driving_force < _zero_tol)
      _slip_increment[_qp][i] = 0.0;
    else
    {
      _slip_increment[_qp][i] =
          _reference_slip_rate * std::pow(driving_force, (1.0 / _rate_sensitivity_exponent));
      if (_tau[_qp][i] < 0.0)
        _slip_increment[_qp][i] *= -1.0;
    }
    if (std::abs(_slip_increment[_qp][i]) * _substep_dt > _slip_incr_tol)
    {
      if (_print_convergence_message)
        mooseWarning("Maximum allowable slip increment exceeded ",
                     std::abs(_slip_increment[_qp][i]) * _substep_dt);
      return false;
    }
  }
  return true;
}

void
CrystalPlasticityOlivineUpdate::calculateEquivalentSlipIncrement(
    RankTwoTensor & equivalent_slip_increment)
{
  CrystalPlasticityStressUpdateBase::calculateEquivalentSlipIncrement(equivalent_slip_increment);
}

void
CrystalPlasticityOlivineUpdate::calculateConstitutiveSlipDerivative(std::vector<Real> & dslip_dtau)
{
  for (const auto i : make_range(_number_slip_systems))
  {
    if (MooseUtils::absoluteFuzzyEqual(_tau[_qp][i], 0.0))
      dslip_dtau[i] = 0.0;
    else
      dslip_dtau[i] = _slip_increment[_qp][i] /
                      (_rate_sensitivity_exponent * std::abs(_tau[_qp][i])) * _substep_dt;
  }
}

bool
CrystalPlasticityOlivineUpdate::areConstitutiveStateVariablesConverged()
{
  if (isConstitutiveStateVariableConverged(_dislocation_density[_qp],
                                           _dislocations_before_update,
                                           _previous_substep_dislocation_density,
                                           _rel_state_var_tol) &&
      isConstitutiveStateVariableConverged(_slip_resistance[_qp],
                                           _slip_resistance_before_update,
                                           _previous_substep_slip_resistance,
                                           _resistance_tol))
    return true;
  return false;
}

void
CrystalPlasticityOlivineUpdate::updateSubstepConstitutiveVariableValues()
{
  _previous_substep_slip_resistance = _slip_resistance[_qp];
  _previous_substep_dislocation_density = _dislocation_density[_qp];
}

void
CrystalPlasticityOlivineUpdate::cacheStateVariablesBeforeUpdate()
{
  _slip_resistance_before_update = _slip_resistance[_qp];
  _dislocations_before_update = _dislocation_density[_qp];
}

void
CrystalPlasticityOlivineUpdate::calculateStateVariableEvolutionRateComponent()
{
  calculateDislocationDensityEvolutionIncrement();
}

void
CrystalPlasticityOlivineUpdate::calculateDislocationDensityEvolutionIncrement()
{

  for (const auto i : make_range(_number_slip_systems))
  {
    const Real abs_slip_increment = std::abs(_slip_increment[_qp][i]);
    Real generated_dislocations = 0.0;

    if (_dislocation_density[_qp][i] > 0.0)
      generated_dislocations = _K_1 * abs_slip_increment * _substep_dt;

    _dislocations_removed_increment[_qp][i] =
        _K_2 * _dislocation_density[_qp][i] * abs_slip_increment * _substep_dt;

    _dislocation_increment[_qp][i] =
        generated_dislocations - _dislocations_removed_increment[_qp][i];
  }
}

void
CrystalPlasticityOlivineUpdate::calculateSlipResistance()
{
  DenseVector<Real> DD_hardening(_number_slip_systems, 0.0);
  DenseVector<Real> lattice_resistance(_number_slip_systems, 0.0);

  unsigned int slip_mode = 0;
  unsigned int counter_adjustment = 0;
  for (const auto i : make_range(_number_slip_systems))
  {
    Real burgers = 0.0;
    if ((i - counter_adjustment) < _number_slip_systems_per_mode[slip_mode])
    {
      burgers = _burgers_vectors[slip_mode];
      lattice_resistance(i) = _tau_c_0[slip_mode];
    }
    else
    {
      counter_adjustment += _number_slip_systems_per_mode[slip_mode];
      ++slip_mode;
      burgers = _burgers_vectors[slip_mode];
      lattice_resistance(i) = _tau_c_0[slip_mode];
    }

    // dislocation density hardening
    if (_dislocation_density[_qp][i] > 0.0)
      DD_hardening(i) =
          _taylor_coefficient * burgers * _shear_modulus * std::sqrt(_dislocation_density[_qp][i]);
    else
      DD_hardening(i) = 0.0;
  }

  // have the constant initial value, while it's not a function of temperature, sum
  for (const auto i : make_range(_number_slip_systems))
    _slip_resistance[_qp][i] = lattice_resistance(i) + DD_hardening(i);
}

bool
CrystalPlasticityOlivineUpdate::updateStateVariables()
{
  if (calculateDislocationDensity())
    return true;
  else
    return false;
}

bool
CrystalPlasticityOlivineUpdate::calculateDislocationDensity()
{
  for (const auto i : make_range(_number_slip_systems))
  {
    if (_previous_substep_dislocation_density[i] < _zero_tol &&
        _dislocation_increment[_qp][i] < 0.0)
      _dislocation_density[_qp][i] = _previous_substep_dislocation_density[i];
    else
      _dislocation_density[_qp][i] =
          _previous_substep_dislocation_density[i] + _dislocation_increment[_qp][i];

    if (_dislocation_density[_qp][i] < 0.0)
      return false;
  }
  return true;
}
