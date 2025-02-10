#pragma once
#include "Material.h"

class Serpentinite : public Material
{
public:
  Serpentinite(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  virtual void computeQpProperties() override;

private:
  ADMaterialProperty<Real> & _eta_s;
};
