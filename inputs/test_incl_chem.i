[Mesh]

  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    ny = 50
    xmax = 1
    ymax = 1
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
    initial_condition = 0
  []

  [V_x]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
  []

  [V_y]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
  []

  [Phi]
    order = FIRST
    family = MONOMIAL
  []

  [X_SiO2]
    order = FIRST
    family = MONOMIAL
    block = 'domain'
  []

  [X_MgO]
    order = FIRST
    family = MONOMIAL
    block = 'domain'
  []

  [lm_Phi]
    order = CONSTANT
    family = MONOMIAL
    block = 'secondary'
  []

  [lm_SiO2]
    order = CONSTANT
    family = MONOMIAL
    block = 'secondary'
  []

  [lm_MgO]
    order = CONSTANT
    family = MONOMIAL
    block = 'secondary'
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
    value = 0.05
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
    value = 0.0
    boundary = 'top'
    variable = V_x
  []

  [top_P_tot]
    type = ADDirichletBC
    boundary = 'top'
    value = 0.0
    variable = P_tot
  []

  [bottom_P_tot]
    type = ADDirichletBC
    boundary = 'bottom'
    value = 0.0
    variable = P_tot
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

  [top_X_SiO2]
    type = ADConservativeAdvectionBC
    boundary = 'top'
    primal_dirichlet_value = 0
    variable = X_SiO2
    velocity_mat_prop = 'velocity'
  []

  [bottom_X_SiO2]
    type = ADConservativeAdvectionBC
    boundary = 'bottom'
    primal_dirichlet_value = 0
    variable = X_SiO2
    velocity_mat_prop = 'velocity'
  []

  [top_X_MgO]
    type = ADConservativeAdvectionBC
    boundary = 'top'
    primal_dirichlet_value = 0
    variable = X_MgO
    velocity_mat_prop = 'velocity'
  []

  [bottom_X_MgO]
    type = ADConservativeAdvectionBC
    boundary = 'bottom'
    primal_dirichlet_value = 0
    variable = X_MgO
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
    outvalue = 0.01
    invalue = 0.1
  []

  [vein_MgO]
    type = BoundingBoxIC
    variable = X_MgO
    x1 = 0.45
    x2 = 0.55
    y1 = 0.0
    y2 = 1.0
    inside = 0.48
    outside = 0.43
  []

  [vein_SiO2]
    type = BoundingBoxIC
    variable = X_SiO2
    x1 = 0.45
    x2 = 0.55
    y1 = 0.0
    y2 = 1.0
    inside = 0.36
    outside = 0.45
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

  [div_v]
    type = VelocityDiv2D
    V_x_s = V_x
    V_y_s = V_y
    variable = P_tot
  []

  [time_phi]
    type = TimeDerivative
    variable = Phi
  []

  [time_X_MgO]
    type = TimeDerivative
    variable = X_MgO
    block = 'domain'
  []

  [time_X_SiO2]
    type = TimeDerivative
    variable = X_SiO2
    block = 'domain'
  []

  [advect_phi]
    type = ADConservativeAdvection
    variable = Phi
    velocity = 'velocity'
    block = 'domain'
  []

  [advect_X_MgO]
    type = ADConservativeAdvection
    variable = X_MgO
    velocity = 'velocity'
    block = 'domain'
  []

  [advect_X_SiO2]
    type = ADConservativeAdvection
    variable = X_SiO2
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

  [X_SiO2_advect]
    type = ADDGAdvection
    variable = X_SiO2
    velocity = 'velocity'
    block = 'domain'
  []

  [X_MgO_advect]
    type = ADDGAdvection
    variable = X_MgO
    velocity = 'velocity'
    block = 'domain'
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

  [ev_SiO2]
    type = EqualValueConstraint
    variable = lm_SiO2
    secondary_variable = X_SiO2
    primary_boundary = 'left'
    primary_subdomain = primary
    secondary_boundary = 'right'
    secondary_subdomain = secondary
    periodic = true
  []

  [ev_MgO]
    type = EqualValueConstraint
    variable = lm_MgO
    secondary_variable = X_MgO
    primary_boundary = 'left'
    primary_subdomain = primary
    secondary_boundary = 'right'
    secondary_subdomain = secondary
    periodic = true
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
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  # l_tol = 1e-6
  # nl_abs_tol = 1e-16
  # nl_rel_tol = 1e-9
  start_time = 0
  end_time = 4

  [Predictor]
    type = SimplePredictor
    scale = 1.0
  []
  # If velocity is too fast it wont work
  # [TimeStepper]
  #   type = AB2PredictorCorrector
  #   dt = 0.1
  #   e_max = 10
  #   e_tol = 1
  # []

  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 5
    dt = 0.01
    growth_factor = 1.25
  []

  #petsc_options = '-pc_svd_monitor'
[]

[Outputs]
  exodus = true
[]

[Debug]
  show_var_residual_norms = false
[]
### Jacobian takes forever due to a framework error in the constraints system.
