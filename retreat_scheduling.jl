using CSV
using DataFrames
using JuMP
using Ipopt
using Gurobi



df = CSV.read("finalfinalfinal.csv",DataFrame)

topics = DataFrames.names(df)
m = length(topics)
people = df.Name
n = length(people)

model = Model(Gurobi.Optimizer)
@variable(model,x[1:n,1:m-2],Bin)

weights = zeros(n,m-2)
for i in 1:n
    priority = df[i,"Priority"]
    for j in 3:m
        interest = df[i,j]
        if ismissing(interest)
            @constraint(model,x[i,j-2]==0)
        elseif interest<0
            @constraint(model,x[i,j-2]==1)
        else
            weights[i,j-2] = interest*priority
        end
        
    end
end


@objective(model,Max,sum(weights.*x))
@constraint(model,[i in 1:n],sum(x[i,:])==2)
@constraint(model,[j in 1:m-2],sum(x[:,j])>=2)
@constraint(model,[j in 1:m-2],sum(x[:,j])<=4)
optimize!(model)

x_mat = Bool.(value.(x))
for i in 1:n
    println("$(people[i]) is doing $(topics[findall(x_mat[i,:]).+2])")
end

    
