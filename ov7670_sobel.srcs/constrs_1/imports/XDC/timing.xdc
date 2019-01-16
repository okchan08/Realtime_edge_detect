# Clock constrains
set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT0]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT1]]]]
set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT0]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT2]]]]
set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT0]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT3]]]]
set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT0]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT4]]]]

set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT1]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT2]]]]
set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT1]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT3]]]]
set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT1]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT4]]]]

set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT2]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT3]]]]
set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT2]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT4]]]]

set_clock_group -asynchronous -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT3]]]] -group [get_clocks [list  [get_clocks -of_objects [get_pins clock_resource/inst/mmcm_adv_inst/CLKOUT4]]]]

