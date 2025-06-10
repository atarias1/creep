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
  second_order = true
[]

[Variables]

  [X_SiO2]
    order = SECOND
    family = LAGRANGE
    #block = 'domain'
  []

  # [lm]
  #   order = FIRST
  #   family = LAGRANGE
  #   block = 'secondary'
  # []
[]

[Kernels]

  [time_X_SiO2]
    type = TimeDerivative
    variable = X_SiO2
    #block = 'domain'
  []

  # [advect_X_SiO2]
  #   type = ADConservativeAdvection
  #   variable = X_SiO2
  #   velocity = 'velocity'
  #   block = 'domain'
  # []

  [advect_X_SiO2_2]
    type = ConservativeAdvection
    variable = X_SiO2
    upwinding_type = FULL
    velocity = '0.1 0 0'
    #block = 'domain'
  []
[]

# [DGKernels]
#   [X_SiO2_advect]
#     type = ADDGAdvection
#     variable = X_SiO2
#     velocity = 'velocity'
#     block = 'domain'
#   []
# []

[ICs]
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

[BCs]
  # [bottom_X_SiO2]
  #   type = ADConservativeAdvectionBC
  #   boundary = 'bottom'
  #   primal_dirichlet_value = 0
  #   variable = X_SiO2
  #   velocity_mat_prop = 'velocity'
  # []
  # [top_X_SiO2]
  #   type = ADConservativeAdvectionBC
  #   boundary = 'top'
  #   primal_dirichlet_value = 0
  #   variable = X_SiO2
  #   velocity_mat_prop = 'velocity'
  # []
  [Periodic]
    [x_X_SiO2]
      variable = X_SiO2
      auto_direction = 'x'
    []
  []
[]

# [Constraints]
#   [ev]
#     type = EqualValueConstraint
#     variable = lm
#     secondary_variable = X_SiO2
#     primary_boundary = 'left'
#     secondary_boundary = 'right'
#     primary_subdomain = primary
#     secondary_subdomain = secondary
#     periodic = true
#   []
# []

# [Materials]
#   [vel]
#     type = ADVectorFromComponentVariablesMaterial
#     vector_prop_name = 'velocity'
#     u = 0.1
#     v = 0.0
#   []
# []

# [Preconditioning]
#   [smp]
#     type = SMP
#     full = true
#   []
# []

[Executioner]
  type = Transient
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  num_steps = 500
  dt = 0.001
  solve_type = NEWTON
[]

[Outputs]
  exodus = true
[]
