<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="PerfMon" version="4.1" date="28/10/2025">
	<VersionSettings gameVersion="1.4.8" windowsVersion="1.0" savedVariablesVersion="1.0" /> 
     <Author name="Caffeine" />
        <Description text="Log elapsed time to a file, enables logging of function calls and events." />
		<Dependencies>
			<Dependency name="EA_UiDebugTools" />
			<Dependency name="LibSlash" />
		</Dependencies>
        <Files>
            <File name="PerfMon.lua" />
        </Files>
        <OnInitialize>
            <CallFunction name="PerfMon.OnInitialize" />
        </OnInitialize>
		<OnUpdate>
			<CallFunction name="PerfMon.OnUpdate" />
		</OnUpdate>
    </UiMod>
</ModuleFile>