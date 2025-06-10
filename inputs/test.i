[Mesh]

  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 75
    ny = 75
    xmax = 1
    ymax = 1
    elem_type = 'QUAD8'
  []
  [nb]
    input = gmg
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '1 1 0'
    block_name = "domain"
  []
  [secondary]
    input = nb
    type = LowerDBlockFromSidesetGenerator
    new_block_name = "secondary"
    sidesets = 'right'
  []
  [primary]
    input = secondary
    type = LowerDBlockFromSidesetGenerator
    new_block_name = "primary"
    sidesets = 'left'
  []
[]

[Variables]

  [P_tot]
    order = FIRST
    family = LAGRANGE
    # initial_condition = 0
  []

  [V_x]
    order = SECOND
    family = LAGRANGE
    initial_condition = 0
  []

  [V_y]
    order = SECOND
    family = LAGRANGE
    initial_condition = 0
  []

  [Phi]
    order = FIRST
    family = MONOMIAL
  []

  [lm_Phi]
    order = CONSTANT
    family = MONOMIAL
    block = 'secondary'
  []

  [lambda]
    family = SCALAR
    order = FIRST
  []
[]

[BCs]
  [bottom_V_y]
    type = ADDirichletBC
    boundary = 'bottom'
    value = 0
    variable = V_y
  []

  [bottom_V_x]
    type = ADDirichletBC
    value = 0.02
    boundary = 'bottom'
    variable = V_x
  []

  [top_V_y]
    type = ADDirichletBC
    boundary = 'top'
    value = 0
    variable = V_y
  []

  [top_V_x]
    type = ADDirichletBC
    value = -0.02
    boundary = 'top'
    variable = V_x
  []

  [top_Phi]
    type = ADConservativeAdvectionBC
    boundary = 'top'
    primal_dirichlet_value = 0
    variable = Phi
    velocity_mat_prop = 'velocity'
  []

  [bottom_Phi]
    type = ADConservativeAdvectionBC
    boundary = 'bottom'
    primal_dirichlet_value = 0
    variable = Phi
    velocity_mat_prop = 'velocity'
  []

  [Periodic]
    [x_V_x]
      variable = V_x
      primary = 'left'
      secondary = 'right'
      translation = '1 0 0'
    []
    [x_V_y]
      variable = V_y
      primary = 'left'
      secondary = 'right'
      translation = '1 0 0'
    []

    [x_P]
      variable = P_tot
      primary = 'left'
      secondary = 'right'
      translation = '1 0 0'
    []
  []
[]

[ICs]
  [circle_phi]
    type = SmoothCircleIC
    variable = Phi
    int_width = 0.1
    x1 = 0.5
    y1 = 0.5
    radius = 0.1
    outvalue = 0.02
    invalue = 0.012
  []
[]

[Materials]
  [Serpentinite]
    type = Serpentinite
    Phi = Phi
    Phi_r = 0.01
    eta_s_ref = 1
    neta = 3
  []

  [vel]
    type = ADVectorFromComponentVariablesMaterial
    vector_prop_name = 'velocity'
    u = V_x
    v = V_y
  []
[]

[Kernels]

  [div_stress_x]
    type = ViscousStress2D
    V_x_s = V_x
    V_y_s = V_y
    P_tot = P_tot
    component = 0
    variable = V_x
  []

  [div_stress_y]
    type = ViscousStress2D
    V_x_s = V_x
    V_y_s = V_y
    P_tot = P_tot
    component = 1
    variable = V_y
  []

  [gravity]
    type = BodyForce
    variable = V_y
    function = '-9.81*y'
  []

  [div_v]
    type = VelocityDiv2D
    V_x_s = V_x
    V_y_s = V_y
    variable = P_tot
  []

  [mean_zero_pressure]
    type = ScalarLagrangeMultiplier
    variable = P_tot
    lambda = lambda
  []

  [time_phi]
    type = TimeDerivative
    variable = Phi
  []

  [advect_phi]
    type = ADConservativeAdvection
    variable = Phi
    velocity = 'velocity'
    block = 'domain'
  []
[]

[DGKernels]

  [Phi_advect]
    type = ADDGAdvection
    variable = Phi
    velocity = 'velocity'
    block = 'domain'
  []
[]

[ScalarKernels]
  [mean_zero_pressure_lm]
    type = AverageValueConstraint
    variable = lambda
    pp_name = pressure_integral
    value = 0
  []
[]

[Constraints]

  [ev_Phi]
    type = EqualValueConstraint
    variable = lm_Phi
    secondary_variable = Phi
    primary_boundary = 'left'
    primary_subdomain = primary
    secondary_boundary = 'right'
    secondary_subdomain = secondary
    periodic = true
  []
[]

[Postprocessors]
  [pressure_integral]
    type = ElementIntegralVariablePostprocessor
    variable = P_tot
    execute_on = linear
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  scheme = 'BDF2'
  solve_type = NEWTON #NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu' # svd for debuging - lu for running
  automatic_scaling = true
  l_tol = 1e-6
  nl_abs_tol = 1e-16
  nl_rel_tol = 1e-9
  start_time = 0
  end_time = 30.0

  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 6
    dt = 0.01
    growth_factor = 1.25
  []

  petsc_options = '-pc_svd_monitor'
[]

[Outputs]
  exodus = true
[]

[Debug]
  show_var_residual_norms = true
  # check_jacobian = true
  # type = FD
[]
### Jacobian takes forever due to a framework error in the constraints system.
