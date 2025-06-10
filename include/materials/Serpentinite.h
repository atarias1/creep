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
  // Inputs
  const Real & _Phi_r;
  const Real & _neta;
  const Real & _eta_s_ref;

  // to be calculated

  ADMaterialProperty<Real> & _eta_s; // Declared here doesnt need const

  // coupled
  const ADVariableValue & _Phi;
};
