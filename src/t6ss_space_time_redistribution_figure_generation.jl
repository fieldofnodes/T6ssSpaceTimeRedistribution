using Pkg; Pkg.activate(".")
using Telegraph
using RandomWalker
using T6SSModellingStochasticTimerRW 




simulation_iterations = 4
parameter_iterations = 50
input_values = pre_defined_params(simulation_iterations,parameter_iterations);

figure_3 = generate_figure_3(input_values)
save("figs/figure_3_a.png",figure_3[:a])
save("figs/figure_3_b.png",figure_3[:b])
save("figs/figure_3_c.png",figure_3[:c])
save("figs/figure_3_d.png",figure_3[:d])

figure_4 = generate_figure_4(input_values)
save("figs/figure_4_a.png",figure_4[:a])
save("figs/figure_4_b.png",figure_4[:b])
save("figs/figure_4_c.png",figure_4[:c])
save("figs/figure_4_d.png",figure_4[:d])

figure_5 = generate_figure_5(input_values)
save("figs/figure_5_a.png",figure_5[:a])
save("figs/figure_5_b.png",figure_5[:b])
save("figs/figure_5_c.png",figure_5[:c])



