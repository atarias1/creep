# This file should test dislocation creep and LTP creep in ol and atg resp.

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = FileMesh
  file = tmesh.msh
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        add_variables = true
        # I think you need to use AD for finite strain
        strain = FINITE
        use_automatic_differentiation = true
        generate_output = 'vonmises_stress'
        material_output_order = SECOND
      []
    []
  []
[]

[BCs]

  [shear_top_x]
    type = ADFunctionDirichletBC
    boundary = top
    variable = disp_x
    function = 't * -0.005'
  []

  [shear_right_y]
    type = ADFunctionDirichletBC
    boundary = right
    variable = disp_y
    function = 't * -0.005'
  []

  [shear_bottom_x]
    type = ADFunctionDirichletBC
    boundary = bottom
    variable = disp_x
    function = 't * 0.005'
  []

  [shear_left_y]
    type = ADFunctionDirichletBC
    boundary = left
    variable = disp_y
    function = 't * 0.005'
  []
[]

[Materials]
  [elasticity1]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 89e9
    poissons_ratio = 0.24
    block = 'inclusion'
  []

  [elasticity2]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 50e8
    poissons_ratio = 0.3
    block = 'matrix'
  []

  [stress]
    # Use finite
    type = ADComputeFiniteStrainElasticStress
  []
[]

[Executioner]
  type = Transient
  # we chose a direct solver here
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  end_time = 10
  dt = 0.5
[]

[Outputs]
  exodus = true
[]

[Debug]
  #show_material_props = true
[]

# units Pa, s, m
