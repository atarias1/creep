/*
This is an addition to the MOOSE framework.
This material model describes the crystal plastic deformation of olivine
based on a similar formulation to Furstoss et al., 2021.

This does not include reduced plasticity.
*/

#pragma once

// Must inherit from this
#include "CrystalPlasticityStressUpdateBase.h"

class CrystalPlasticityOlivineUpdate;

class CrystalPlasticityOlivineUpdate : public CrystalPlasticityStressUpdateBase
{

public:
  static InputParameters validParams();

  CrystalPlasticityOlivineUpdate(const InputParameters & parameters);

protected:
  /**
   * initializes the stateful properties such as
   * stress, plastic deformation gradient, slip system resistances, etc.
   */
  virtual void initQpStatefulProperties() override;

  /**
   * Sets the value of the current and previous substep iteration slip system
   * resistance to the old value at the start of the PK2 stress convergence
   * while loop.
   */
  virtual void setInitialConstitutiveVariableValues() override;

  /**
   * Sets the current slip system resistance value to the previous substep value.
   * In cases where only one substep is taken (or when the first) substep is taken,
   * this method just sets the current value to the old slip system resistance
   * value again.
   */
  virtual void setSubstepConstitutiveVariableValues() override;

  /**
   * Stores the current value of the slip system resistance into a separate
   * material property in case substepping is needed.
   */
  virtual void updateSubstepConstitutiveVariableValues() override;

  virtual bool calculateSlipRate() override;

  virtual void
  calculateEquivalentSlipIncrement(RankTwoTensor & /*equivalent_slip_increment*/) override;

  virtual void calculateConstitutiveSlipDerivative(std::vector<Real> & dslip_dtau) override;

  // Cache the slip system value before the update for the diff in the convergence check
  virtual void cacheStateVariablesBeforeUpdate() override;

  // Contitutive model goes here with a convergence check
  virtual void calculateStateVariableEvolutionRateComponent() override;

  /*
   * Finalizes the values of the state variables and slip system resistance
   * for the current timestep after convergence has been reached.
   */
  virtual bool updateStateVariables() override;

  // new function for updating dislocation density

  /*
    Calculates the evolution increment of glide dislocation densities for
    each slip system. From Furstoss et al., 2021
    $\dot{\rho}^\alpha = (K_1 - K_2 \rho^\alpha)|\dot{gamma}^\alpha$

  */
  void calculateDislocationDensityEvolutionIncrement();

  /*
    Calculates the current value of the incremented dislocation density on each
    slip system
  */

  void calculateDislocationDensity();

  /*
    Calculates the sum of all slip system dislocations and uses it to determing the
    slip resistence from Furstoss et al., 2021:
    $\tau_c ^ \alpha = \tau_{c0}^\alpha + \psi \mu b^\alpha \sqrt{\rho^{total}}$
  */

  virtual void calculateSlipResistance() override;

  /**
   * Determines if the state variables, e.g. defect densities, have converged
   * by comparing the change in the values over the iteration period.
   */
  virtual bool areConstitutiveStateVariablesConverged() override;

  // Variables & Parameters

  // Dislocation densities
  MaterialProperty<std::vector<Real>> & _dislocation_density;
  const MaterialProperty<std::vector<Real>> & dislocation_density_old;
  MaterialProperty<std::vector<Real>> & dislocation_increment;
  const Real _initial_dislocation_density;

  // Slip systems -- I think here we just care about the burgers vector
  const unsigned int _slip_system_modes;

  // Here we can split the slip systems based on their burgers vector
  const std::vector<unsigned int> _number_slip_systems_per_mode;

  // Initial slip resistence | arranged per each slip systems
  const std::vector<Real> _tau_c_0;

  // Parameters for slip rate calculation - same for each slip system
  const Real _reference_slip_rate;
  const Real _rate_sensitivity_exponent;

  // Parameters for determining slip resistence
  const std::vector<Real> _burgers_vector;
  const Real _taylor_coefficient;
  const Real _shear_modulus;

  // Hardening/softening parameters
  const Real _K_1;
  const Real _K_2;

  ///@{Stores the slip system resistance, dislocation densities from the previous substep
  std::vector<Real> _previous_substep_slip_resistance;
  std::vector<Real> _previous_substep_dislocation_density;
  ///@}
};
