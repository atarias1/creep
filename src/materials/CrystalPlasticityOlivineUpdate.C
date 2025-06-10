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
}
