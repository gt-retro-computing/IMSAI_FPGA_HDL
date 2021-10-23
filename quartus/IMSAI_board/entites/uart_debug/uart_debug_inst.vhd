	component uart_debug is
		port (
			source : out std_logic_vector(9 downto 0);                    -- source
			probe  : in  std_logic_vector(0 downto 0) := (others => 'X')  -- probe
		);
	end component uart_debug;

	u0 : component uart_debug
		port map (
			source => CONNECTED_TO_source, -- sources.source
			probe  => CONNECTED_TO_probe   --  probes.probe
		);

