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
    order = FIRST
    family = LAGRANGE
  []

  [V_y]
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
    value = 1e-12
    variable = V_x
  []

  [Periodic]
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
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  #petsc_options = '-pc_svd_monitor'
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
