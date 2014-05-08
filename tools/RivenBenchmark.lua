--benchmark Riven by Jus
--ty Dienofail for this ideia!

local bench = 0

function OnLoad()
	print("BenchMark Riven Loaded.")
end

function OnAnimation(unit, animationname)
	if unit.isMe then
		if animationname:lower():find("spell1a") then bench = GetTickCount() end

		if animationname:lower():find("spell1c") then
    		print("Benchmark Triple Q: "..tostring( (GetTickCount() - bench) ).." mseconds/ "..tostring( (GetTickCount() - bench)/1000 ) .." seconds")
   		end
   	end
end
