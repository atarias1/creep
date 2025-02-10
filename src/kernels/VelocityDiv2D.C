#include "VelocityDiv2D.h"

registerMooseObject("CreepApp", VelocityDiv2D);

InputParameters
VelocityDiv2D::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredCoupledVar("V_x_s", "x velocity");
  params.addRequiredCoupledVar("V_y_s", "y velocity");
  return params;
}

VelocityDiv2D::VelocityDiv2D(const InputParameters & parameters)
  : ADKernel(parameters), _V_x_s(adCoupledValue("V_x_s")), _V_y_s(adCoupledValue("V_y_s"))
{
}

ADReal
VelocityDiv2D::computeQpResidual()
{
  ADRealVectorValue V_s = (_V_x_s[_qp], _V_y_s[_qp]);
  return -_grad_test[_i][_qp] * V_s;
}
