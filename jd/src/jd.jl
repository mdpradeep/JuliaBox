module jd

	using Images
	using Compat
	using JuliaWebAPI
	using Logging

	include("consts.jl")

	export calculateBudget

	calculateBudget(;jsonString::AbstractString="") =
							__calculateBudget(jsonString)

	function __calculateBudget(jsonString::AbstractString) 
		println("Calculate Budget !!!  ::: $jsonString")	
		if jsonString == ""
			return "No Data"
		end
		return jsonString
	end

	const JULIABOX_APIS = [
			(calculateBudget, true, JSON_HEADER)
	]

	serve_juliabox() = process(JULIABOX_APIS)

	serve_local() = process(JULIABOX_APIS, "tcp://127.0.0.1:9999";
		bind=true, log_level=DEBUG)

end # module
