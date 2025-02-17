[Mesh]

  [file]
    type = FileMeshGenerator
    file = square.msh
  []

  [secondary]
    input = file
    type = LowerDBlockFromSidesetGenerator
    new_block_id = 11
    new_block_name = "secondary"
    sidesets = '101'
  []
  [primary]
    input = secondary
    type = LowerDBlockFromSidesetGenerator
    new_block_id = 12
    new_block_name = "primary"
    sidesets = '103'
  []

  # [gmg]
  #   type = GeneratedMeshGenerator
  #   dim = 2
  #   nx = 50
  #   ny = 50
  #   nz = 0

  #   xmax = 1
  #   ymax = 1
  #   zmax = 0
  # []

  # [secondary]
  #   input = gmg
  #   type = LowerDBlockFromSidesetGenerator
  #   sidesets = 'right'
  #   new_block_name = "secondary"
  # []
  # [primary]
  #   input = secondary
  #   type = LowerDBlockFromSidesetGenerator
  #   sidesets = 'left'
  #   new_block_name = "primary"
  # []
[]

[Variables]
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
    family = LAGRANGE
  []

  [X_SiO2]
    order = FIRST
    family = MONOMIAL
    block = 'domain'
  []

  [X_MgO]
    order = FIRST
    family = LAGRANGE
  []

  [lm]
    order = CONSTANT
    family = MONOMIAL
    block = secondary
  []
[]

[BCs]
  [bottom_V_y]
    type = ADDirichletBC
    boundary = 'bottom'
    value = 0
    variable = V_y
  []

  # [bottom_V_x]
  #   type = ADFunctionDirichletBC
  #   boundary = 'bottom'
  #   function = '0.10 * tanh(t*50)'
  #   variable = V_x
  # []

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
    [x_Phi]
      variable = Phi
      auto_direction = 'x'
    []

    # [x_SiO2]
    #   variable = X_SiO2
    #   auto_direction = 'x'
    # []

    [x_MgO]
      variable = X_MgO
      auto_direction = 'x'
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
    neta = 2
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
    component = 0
    variable = V_x
  []

  [div_stress_y]
    type = ViscousStress2D
    V_x_s = V_x
    V_y_s = V_y
    component = 1
    variable = V_y
  []

  [time_phi]
    type = TimeDerivative
    variable = Phi
  []

  [time_X_MgO]
    type = TimeDerivative
    variable = X_MgO
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
  []

  [advect_X_MgO]
    type = ADConservativeAdvection
    variable = X_MgO
    velocity = 'velocity'
  []

  # [advect_X_SiO2]
  #   type = ADConservativeAdvection
  #   variable = X_SiO2
  #   velocity = 'velocity'
  # []
[]

[DGKernels]
  [X_SiO2_advect]
    type = ADDGAdvection
    variable = X_SiO2
    velocity = 'velocity'
    block = 'domain'
  []
[]

[Constraints]
  [ev]
    type = EqualValueConstraint
    variable = lm
    secondary_variable = X_SiO2
    primary_boundary = 'left'
    primary_subdomain = 103
    secondary_boundary = 101
    secondary_subdomain = 11
    periodic = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'svd'
  automatic_scaling = true
  num_steps = 25
  dt = 0.005
  petsc_options = '-pc_svd_monitor'
[]

[Outputs]
  exodus = true
[]

[Debug]
  show_var_residual_norms = false
[]
