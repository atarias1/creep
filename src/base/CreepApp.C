#include "CreepApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
CreepApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

CreepApp::CreepApp(InputParameters parameters) : MooseApp(parameters)
{
  CreepApp::registerAll(_factory, _action_factory, _syntax);
}

CreepApp::~CreepApp() {}

void
CreepApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<CreepApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"CreepApp"});
  Registry::registerActionsTo(af, {"CreepApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
CreepApp::registerApps()
{
  registerApp(CreepApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
CreepApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  CreepApp::registerAll(f, af, s);
}
extern "C" void
CreepApp__registerApps()
{
  CreepApp::registerApps();
}
