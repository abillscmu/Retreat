using CSV
using DataFrames
using JuMP
using Ipopt
using Gurobi



df = CSV.read("groupmembership.csv",DataFrame)

topics = DataFrames.names(df)
m = length(topics)
people = df.Name
n = length(people)

model = Model(Gurobi.Optimizer)
@variable(model,g_1[1:m-2],Bin)
@variable(model,g_2[1:m-2],Bin)

x = zeros(n,m-2)
for i in 1:n
    for j in 3:m
        interest = df[i,j]
        if ismissing(interest)
            x[i,j-2]=0
        else
            x[i,j-2]=1
        end
        
    end
end


@objective(model,Min,sum(x*g_1)+sum(x*g_2))
@constraint(model,[j in 1:m-2],g_1[j]+g_2[j]==1)
@constraint(model,[i in 1:n],x[i,:]'*g_1>=1)
@constraint(model,[i in 1:n],x[i,:]'*g_2>=1)
optimize!(model)

    