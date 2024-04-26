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


"""
To generate the data and figures 4 and 5
"""

figure_4 = generate_figure_4_a_bc_d(input_values)
save("figs/figure_4_a.png",figure_4[:a])
save("figs/figure_4_bc.png",figure_4[:bc])
save("figs/figure_4_d.png",figure_4[:d])

figure_5 = generate_figure_5_ab_c(input_values)
save("figs/figure_5_ab.png",figure_5[:ab])
save("figs/figure_5_c.png",figure_5[:c])




"""
To just generate figures 4 and 5, fun the following
"""



"""
Figure 4:
1. Generic time series
2. Small value of λ₀
3. Large value of λ₀
4. Range of λ₀ and extpected distance travelled
"""

iters_get_values = generate_iters_get_values()
figs4a = generate_figure_4_a(input_values)
figs4bc = generate_figure_4_bc(input_values,iters_get_values)
figs4d = generate_figure_4_d(input_values,iters_get_values)

save("figs/figure_4_a.png",figs4a)
save("figs/figure_4_bc.png",figs4bc)
save("figs/figure_4_d.png",figs4d)

"""
Figure 5:
1. Small value of D
2. Large value of D
3. Range of D and extpected distance travelled
"""

figs5ab = generate_figure_5_ab(input_values,iters_get_values)
figs5c = generate_figure_5_c(input_values,iters_get_values)
save("figs/figure_5_ab.png",figs5ab)
save("figs/figure_5_c.png",figs5c)






