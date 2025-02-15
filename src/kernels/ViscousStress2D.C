#include "ViscousStress2D.h"

// lacks pressure at the moment

registerMooseObject("CreepApp", ViscousStress2D);

InputParameters
ViscousStress2D::validParams()
{
  InputParameters params = ADKernel::validParams();

  params.addRequiredParam<unsigned int>("component", "Velocity component.");
  params.addRequiredCoupledVar("V_x_s", "x velocity");
  params.addRequiredCoupledVar("V_y_s", "y velocity");
  // params.addRequiredCoupledVar("P_tot", "Total pressure");

  return params;
}

ViscousStress2D::ViscousStress2D(const InputParameters & parameters)
  : ADKernel(parameters),

    // Params
    _component(getParam<unsigned int>("component")),

    // Coupled
    _V_x_s(adCoupledValue("V_x_s")),
    _V_y_s(adCoupledValue("V_y_s")),
    // _P_tot(adCoupledValue("P_tot")),

    _grad_V_x_s(adCoupledGradient("V_x_s")),
    _grad_V_y_s(adCoupledGradient("V_y_s")),

    // Required Material Properties
    _eta_s(getADMaterialProperty<Real>("eta_s"))
{
}

// There is no coupled P_f since in this kernel the main variable "u" is fluid pressure

ADReal
ViscousStress2D::computeQpResidual()
{

  ADReal res;

  // // Velocity gradient components
  // const ADReal dvx_dx = _grad_V_x_s[_qp](0);
  // const ADReal dvx_dy = _grad_V_x_s[_qp](1);
  // const ADReal dvy_dx = _grad_V_y_s[_qp](0);
  // const ADReal dvy_dy = _grad_V_y_s[_qp](1);

  // // const ADReal div_v = dvx_dx + dvy_dy;

  // // stress components

  // const ADReal sigma_xx = (dvx_dx); // removed - _P_tot[_qp] from front
  // // div_v = 0, so - div_v / 3.0 removed
  // const ADReal sigma_yy = (dvy_dy); // removed - _P_tot[_qp] from front

  // Residual
  if (_component == 0)
  {
    res = -1 * ((_grad_test[_i][_qp](0) * (2.0 * _eta_s[_qp] * _grad_u[_qp](0))) +
                (_grad_test[_i][_qp](1) * (_eta_s[_qp] * (_grad_u[_qp](1) + _grad_V_y_s[_qp](0)))));
  }

  else if (_component == 1)
  {
    res = -1 * ((_grad_test[_i][_qp](0) * (_eta_s[_qp] * (_grad_u[_qp](0) + _grad_V_x_s[_qp](1)))) +
                (_grad_test[_i][_qp](1) * (2.0 * _eta_s[_qp] * _grad_u[_qp](1))));
  }

  return res;
}
