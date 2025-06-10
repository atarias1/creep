#include "Serpentinite.h"

registerMooseObject("CreepApp", Serpentinite);

InputParameters
Serpentinite::validParams()
{
  InputParameters params = Material::validParams();

  params.addRequiredParam<Real>("Phi_r", "Background porosity");
  params.addRequiredParam<Real>("neta", "Viscosity exponent");
  params.addRequiredParam<Real>("eta_s_ref", "Reference viscosity");

  params.addRequiredCoupledVar("Phi", "Porosity");

  return params;
}

Serpentinite::Serpentinite(const InputParameters & parameters)
  : Material(parameters),

    _Phi_r(getParam<Real>("Phi_r")),
    _neta(getParam<Real>("neta")),
    _eta_s_ref(getParam<Real>("eta_s_ref")),

    _eta_s(declareADProperty<Real>("eta_s")),
    _Phi(adCoupledValue("Phi"))

{
}

void
Serpentinite::computeQpProperties()
{
  _eta_s[_qp] = _eta_s_ref * std::pow(_Phi_r / _Phi[_qp], _neta);
}
