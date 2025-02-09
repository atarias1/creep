//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "CreepTestApp.h"
#include "CreepApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
CreepTestApp::validParams()
{
  InputParameters params = CreepApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

CreepTestApp::CreepTestApp(InputParameters parameters) : MooseApp(parameters)
{
  CreepTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

CreepTestApp::~CreepTestApp() {}

void
CreepTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  CreepApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"CreepTestApp"});
    Registry::registerActionsTo(af, {"CreepTestApp"});
  }
}

void
CreepTestApp::registerApps()
{
  registerApp(CreepApp);
  registerApp(CreepTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
CreepTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  CreepTestApp::registerAll(f, af, s);
}
extern "C" void
CreepTestApp__registerApps()
{
  CreepTestApp::registerApps();
}
