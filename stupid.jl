
N,xwidth,ylength,boundary = 3,20,20,"double_periodic"
test_get_positions = get_walker_position(λ₀Δt,λ₁Δt,hΔt,t⃗,N,xwidth,ylength,boundary)
number_first_is_last = findall([test_get_positions[i][:first_walker] == test_get_positions[i][:last_walker] for i in 1:10^N])
solution = get_distance_count_sample_experimental(test_get_positions,xwidth,ylength,N,boundary)



dark_cyan = colorant"#006390"
sindx = size(solution[:indx],1)
lims = Tuple(reshape([-1/2,1/2].*[xwidth ylength],4,1))
axis = (width = 512, height = 512,aspect=1,xlimits = (0,sindx))
norm_count_bar = 
data(solution) *
mapping(:indx => L"d",keys(solution)[5] => L"count") * 
visual(BarPlot,color=dark_cyan)
fnorm_count_bar = draw(norm_count_bar;axis = axis)


tab_dist_count = (
    x = repeat(solution[:indx],outer = sindx),
    y = vcat(
        solution[:count_experimental],
        solution[:count_sample]),
    c = repeat(["Experimental", "Sample"],inner = sindx))
dist_count_bar = data(tab_dist_count) *
    mapping(:x => L"d",:y => L"count",color = :c => "Group") *
    visual(BarPlot, alpha = 0.4)
fdist_count_bar = draw(
    dist_count_bar;
    axis = axis, 
    legend=(position=:top, titleposition=:left, framevisible=true, padding=5))














filter(==(0),solution[:distance_sample])
filter(==(0),solution[:distances_experimental])

solution[:distances_experimental]



