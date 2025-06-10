[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  nz = 0

  xmax = 1
  ymax = 1
  zmax = 0
  elem_type = QUAD4
  #second_order = true
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
[]

[BCs]
  [bottom_V_y]
    type = ADDirichletBC
    boundary = 'bottom'
    value = 0
    variable = V_y
  []

  [bottom_V_x]
    type = ADFunctionDirichletBC
    boundary = 'bottom'
    function = '0.10 * tanh(t*50)'
    variable = V_x
  []

  [top_V_y]
    type = ADDirichletBC
    boundary = 'top'
    value = 0
    variable = V_y
  []

  [top_V_x]
    type = ADFunctionDirichletBC
    boundary = 'top'
    function = '-0.10 * tanh(t*50)'
    variable = V_x
  []

  # [top_Phi]
  #   type = ADConservativeAdvectionBC
  #   boundary = 'top'
  #   primal_dirichlet_value = 0
  #   variable = Phi
  #   velocity_mat_prop = 'velocity'
  # []

  # [bottom_Phi]
  #   type = ADConservativeAdvectionBC
  #   boundary = 'bottom'
  #   primal_dirichlet_value = 0
  #   variable = Phi
  #   velocity_mat_prop = 'velocity'
  # []

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
    [x_Phi]
      variable = Phi
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
    outvalue = 0.02
    invalue = 0.1
  []
[]

[Materials]
  [Serpentinite]
    type = Serpentinite
    Phi = Phi
    Phi_r = 0.01
    eta_s_ref = 100
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

  [advect_phi]
    type = ADConservativeAdvection
    variable = Phi
    velocity = 'velocity'
  []
[]

# [DGKernels]
#   [phi_advect]
#     type = ADDGAdvection
#     variable = Phi
#     velocity = 'velocity'
#   []
# []

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  num_steps = 250
  dt = 0.005
  #petsc_options = '-pc_svd_monitor'
  #steady_state_detection = true
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
