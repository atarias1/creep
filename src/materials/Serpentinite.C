#include "Serpentinite.h"

registerMooseObject("CreepApp", Serpentinite);

InputParameters
Serpentinite::validParams()
{
  InputParameters params = Material::validParams();

  return params;
}

Serpentinite::Serpentinite(const InputParameters & parameters)
  : Material(parameters),

    _eta_s(declareADProperty<Real>("eta_s"))

{
}

void
Serpentinite::computeQpProperties()
{
  _eta_s[_qp] = 1.0;
}
