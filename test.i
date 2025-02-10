[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  nz = 0

  xmax = 20
  ymax = 20
  zmax = 0
  elem_type = QUAD4
  second_order = true
[]

[Variables]
  [V_x]
    order = SECOND
    family = LAGRANGE
  []

  [V_y]
    order = SECOND
    family = LAGRANGE
  []

  [P_tot]
    order = FIRST
    family = LAGRANGE
  []
[]

[ICs]
  [V_x]
    type = ConstantIC
    value = 0.0
    variable = V_x
  []

  [V_y]
    type = ConstantIC
    value = 0.0
    variable = V_y
  []

  [P_tot]
    type = ConstantIC
    value = 1
    variable = P_tot
  []
[]

[BCs]
  active = 'bottom_V_x bottom_V_y top_V_x top_V_y bottom_P top_P'
  [bottom_V_y]
    type = ADDirichletBC
    boundary = 'bottom'
    value = 0
    variable = V_y
  []

  [bottom_V_x]
    type = ADDirichletBC
    boundary = 'bottom'
    value = 0
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
    boundary = 'top'
    value = 1
    variable = V_x
  []

  [bottom_P]
    type = ADNeumannBC
    boundary = 'bottom'
    variable = P_tot
    value = 0
  []

  [top_P]
    type = ADNeumannBC
    boundary = 'top'
    variable = P_tot
    value = 0
  []

  [Periodic]
    # active = 'x_V_x x_V_y x_P'
    [x_V_x]
      variable = V_x
      primary = 'left'
      secondary = 'right'
      translation = '20 0 0'
    []
    [x_V_y]
      variable = V_y
      primary = 'left'
      secondary = 'right'
      translation = '20 0 0'
    []

    [x_P]
      variable = P_tot
      primary = 'left'
      secondary = 'right'
      translation = '20 0 0'
    []
  []
[]

[Materials]
  [Serpentinite]
    type = Serpentinite
  []
[]

[Kernels]
  [div_stress_x]
    type = ViscousStress2D
    P_tot = P_tot
    V_x_s = V_x
    V_y_s = V_y
    component = 0
    variable = V_x
  []

  [div_stress_y]
    type = ViscousStress2D
    P_tot = P_tot
    V_x_s = V_x
    V_y_s = V_y
    component = 1
    variable = V_y
  []

  [pressure]
    type = VelocityDiv2D
    V_x_s = V_x
    V_y_s = V_y
    variable = P_tot
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'svd'
  end_time = 1
  dt = 1
  automatic_scaling = true
  petsc_options = '-pc_svd_monitor'
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
