-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.net.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_noc_csr_pkg.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.tiles_asic_pkg.all;
use work.pads_loc.all;

entity ESP_ASIC_TOP is
  generic (
    SIMULATION : boolean := false);
  port (
    reset           : in    std_logic;
    -- Backup external clocks for selected tiles and NoC
    ext_clk         : in    std_logic;
    clk_div         : out   std_logic;
    -- < FPGA proxy memory link >
    -- < I/O link >
    -- < Ethernet signals >
    -- < JTAG >
    -- UART
    uart_rxd        : in    std_logic;  -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_logic;  -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn       : out   std_logic   -- UART1_RTSN (u1o.rtsn)
   );
end;



architecture rtl of ESP_ASIC_TOP is


  type handshake_vec is array (CFG_TILES_NUM-1 downto 0) of std_logic_vector(3 downto 0);
  type boolean_vec is array (natural range <>) of boolean;

  constant is_io_tile : boolean_vec(0 to CFG_TILES_NUM-1) := (io_tile_id => true, others => false);

  -- NOC Signals
  signal noc1_data_n_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_s_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_w_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_e_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_void_in  : handshake_vec;
  signal noc1_stop_in       : handshake_vec;
  signal noc1_data_n_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_s_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_w_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_e_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_void_out : handshake_vec;
  signal noc1_stop_out      : handshake_vec;
  signal noc2_data_n_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_s_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_w_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_e_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_void_in  : handshake_vec;
  signal noc2_stop_in       : handshake_vec;
  signal noc2_data_n_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_s_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_w_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_e_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_void_out : handshake_vec;
  signal noc2_stop_out      : handshake_vec;
  signal noc3_data_n_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_s_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_w_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_e_in     : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_void_in  : handshake_vec;
  signal noc3_stop_in       : handshake_vec;
  signal noc3_data_n_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_s_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_w_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_e_out    : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_void_out : handshake_vec;
  signal noc3_stop_out      : handshake_vec;
  signal noc4_data_n_in     : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_s_in     : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_w_in     : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_e_in     : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_void_in  : handshake_vec;
  signal noc4_stop_in       : handshake_vec;
  signal noc4_data_n_out    : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_s_out    : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_w_out    : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_e_out    : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_void_out : handshake_vec;
  signal noc4_stop_out      : handshake_vec;
  signal noc5_data_n_in     : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_s_in     : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_w_in     : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_e_in     : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_void_in  : handshake_vec;
  signal noc5_stop_in       : handshake_vec;
  signal noc5_data_n_out    : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_s_out    : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_w_out    : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_e_out    : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_void_out : handshake_vec;
  signal noc5_stop_out      : handshake_vec;
  signal noc6_data_n_in     : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_s_in     : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_w_in     : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_e_in     : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_void_in  : handshake_vec;
  signal noc6_stop_in       : handshake_vec;
  signal noc6_data_n_out    : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_s_out    : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_w_out    : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_e_out    : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_void_out : handshake_vec;
  signal noc6_stop_out      : handshake_vec;

  signal noc1_data_l_in          : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_l_out         : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_void_in_tile  : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_void_out_tile : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_stop_in_tile       : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_stop_out_tile      : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_l_in          : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_l_out         : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_void_in_tile  : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_void_out_tile : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_stop_in_tile       : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_stop_out_tile      : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_l_in          : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_l_out         : coh_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_void_in_tile  : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_void_out_tile : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_stop_in_tile       : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_stop_out_tile      : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_l_in          : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_l_out         : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_void_in_tile  : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_void_out_tile : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_stop_in_tile       : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_stop_out_tile      : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_l_in          : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_l_out         : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_void_in_tile  : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_void_out_tile : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_stop_in_tile       : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_stop_out_tile      : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_l_in          : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_l_out         : dma_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_void_in_tile  : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_void_out_tile : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_stop_in_tile       : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_stop_out_tile      : std_logic_vector(CFG_TILES_NUM-1 downto 0);
 
  type mon_noc_vector is array (CFG_TILES_NUM-1 downto 0) of monitor_noc_vector(1 to 6);
  signal mon_noc                 : mon_noc_vector;

  -- DCO config
  type dco_clk_delay_sel_vector is array (CFG_TILES_NUM-1 downto 0) of std_logic_vector(11 downto 0);
  type dco_freq_sel_vector      is array (CFG_TILES_NUM-1 downto 0) of std_logic_vector(1 downto 0);
  type dco_cc_sel_vector        is array (CFG_TILES_NUM-1 downto 0) of std_logic_vector(5 downto 0);
  type dco_fc_sel_vector        is array (CFG_TILES_NUM-1 downto 0) of std_logic_vector(5 downto 0);
  type dco_div_sel_vector       is array (CFG_TILES_NUM-1 downto 0) of std_logic_vector(2 downto 0);

  signal dco_en            : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal dco_clk_sel       : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal dco_cc_sel        : dco_cc_sel_vector; 
  signal dco_fc_sel        : dco_fc_sel_vector; 
  signal dco_div_sel       : dco_div_sel_vector;
  signal dco_freq_sel      : dco_freq_sel_vector; 
  signal dco_clk_delay_sel : dco_clk_delay_sel_vector;


  -- Global NoC reset and clock
  signal noc_clk       : std_ulogic;
  signal noc_rstn      : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal raw_rstn      : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal noc_clk_lock  : std_ulogic;
  signal tile_clk      : std_logic_vector(CFG_TILES_NUM-1 downto 0); 
  signal tile_rstn     : std_logic_vector(CFG_TILES_NUM-1 downto 0); 
 
  -- I/O for PADS
  constant pad_fixed_cfg : std_logic_vector(19 - (ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB + 1) downto 0) := (others => '0');
  type pad_cfg_full_array is array (0 to CFG_TILES_NUM - 1) of std_logic_vector(19 downto 0);
  type pad_cfg_array is array (0 to CFG_TILES_NUM - 1) of std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
  -- Current default configuration is SR=0, DS1=1, DS0=1
  signal pad_cfg : pad_cfg_array;
  signal full_pad_cfg : pad_cfg_full_array;

  -- LDO Controller
  type ldo_ctrl_array is array (0 to CFG_TILES_NUM - 1) of std_logic_vector(7 downto 0);
  signal ldo_ctrl : ldo_ctrl_array;

  -- External clocks and reset
  signal reset_int   : std_logic;
  signal ext_clk_int : std_logic;  -- backup tile clock
  signal clk_div_int : std_logic_vector(0 to CFG_TILES_NUM - 1);  -- tile clock monitor for testing purposes
  signal ext_clk_noc_int : std_logic;
  signal clk_div_noc_int : std_logic;

  -- Test interface
  signal tdi_int  : std_logic_vector(0 to CFG_TILES_NUM - 1);
  signal tdo_int  : std_logic_vector(0 to CFG_TILES_NUM - 1);
  signal tms_int  : std_logic;
  signal tclk_int : std_logic;

  -- FPGA proxy
  signal fpga_oen            : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_data_in        : std_logic_vector(CFG_NMEM_TILE * (CFG_MEM_LINK_BITS) - 1 downto 0);
  signal fpga_data_out       : std_logic_vector(CFG_NMEM_TILE * (CFG_MEM_LINK_BITS) - 1 downto 0);
  signal fpga_valid_in_int   : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_valid_out_int  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_in_int     : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_out_int    : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_in_int  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_out_int : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);

  -- Use these signals to generate pad configuration
  signal fpga_oen_int        : std_logic_vector(CFG_NMEM_TILE * (CFG_MEM_LINK_BITS) - 1 downto 0);
  signal fpga_data_pad_cfg   : std_logic_vector(CFG_NMEM_TILE * (CFG_MEM_LINK_BITS) * 20 - 1 downto 0);
  signal fpga_c_pad_cfg      : std_logic_vector(CFG_NMEM_TILE * 20 - 1 downto 0);

  -- I/O Link
  signal iolink_data_ien                             : std_ulogic;
  signal iolink_data_oen                             : std_ulogic;
  signal iolink_data_in_int                          : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_data_out_int                         : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_valid_in_int                         : std_ulogic;
  signal iolink_valid_out_int, iolink_valid_out_io   : std_ulogic;
  signal iolink_clk_in_int                           : std_ulogic;
  signal iolink_clk_out_int, iolink_clk_out_io       : std_ulogic;
  signal iolink_credit_in_int                        : std_ulogic;
  signal iolink_credit_out_int, iolink_credit_out_io : std_ulogic;

  -- Ethernet signals
  signal reset_o2_int    : std_ulogic;
  signal etx_clk_int     : std_ulogic;
  signal erx_clk_int     : std_ulogic;
  signal erxd_int        : std_logic_vector(3 downto 0);
  signal erx_dv_int      : std_ulogic;
  signal erx_er_int      : std_ulogic;
  signal erx_col_int     : std_ulogic;
  signal erx_crs_int     : std_ulogic;
  signal etxd_int        : std_logic_vector(3 downto 0);
  signal etx_en_int      : std_ulogic;
  signal etx_er_int      : std_ulogic;
  signal emdc_int        : std_ulogic;
  signal emdio_i         : std_logic;
  signal emdio_o         : std_logic;
  signal emdio_oe        : std_logic;

  -- UART
  signal uart_rxd_int    : std_logic;   -- UART1_RX (u1i.rxd)
  signal uart_txd_int    : std_logic;   -- UART1_TX (u1o.txd)
  signal uart_ctsn_int   : std_logic;   -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int   : std_logic;   -- UART1_RTSN (u1o.rtsn)

  signal cpuerr_vec      : std_ulogic_vector(0 to CFG_NCPU_TILE-1);

begin

  --pragma translate_off
  process(noc_clk, noc_rstn(0))
  begin  -- process
    if noc_rstn(0) = '1' then
      assert cpuerr_vec(0) = '0' report "Program Completed!" severity failure;
    end if;
  end process;
  --pragma translate_on

  -----------------------------------------------------------------------------
  -- PADS
  -----------------------------------------------------------------------------

  pad_cfg_gen : for i in 0 to CFG_TILES_NUM - 1 generate
    full_pad_cfg(i) <= pad_fixed_cfg & pad_cfg(i);
  end generate pad_cfg_gen;

  reset_pad : inpad generic map (loc => reset_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (reset, reset_int);
  -- ext_clk and div_clk for NoC (DCO located in the I/O tile)
  ext_clk_pad : inpad generic map (loc => ext_clk_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ext_clk, ext_clk_int);
  clk_div_pad : outpad generic map (loc => clk_div_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (clk_div, clk_div_noc_int, full_pad_cfg(io_tile_id));

  -- Tile test
  -- TODO has to be generated according to pads_loc.txt
  -- < JTAG pads >

  -- Ethernet
  -- < ETH pads >

  -- Memory link
  -- < Memory link pads >

  --IO link
  -- < I/O link pads >

  -- UART
  uart_rxd_pad  : inpad generic map (loc => uart_rxd_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad  : outpad generic map (loc => uart_txd_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_txd, uart_txd_int, full_pad_cfg(io_tile_id));
  uart_ctsn_pad : inpad generic map (loc => uart_ctsn_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_ctsn, uart_ctsn_int);
  uart_rtsn_pad : outpad generic map (loc => uart_rtsn_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rtsn, uart_rtsn_int, full_pad_cfg(io_tile_id));


  -----------------------------------------------------------------------------
  -- NOC CONNECTIONS
  -----------------------------------------------------------------------------
  meshgen_y : for i in 0 to CFG_YLEN-1 generate
    meshgen_x : for j in 0 to CFG_XLEN-1 generate

      y_0 : if (i = 0) generate
        -- North port is unconnected
        noc1_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc1_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc1_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc2_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc2_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc2_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc3_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc3_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc3_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc4_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc4_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc4_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc5_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc5_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc5_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc6_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc6_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc6_stop_in(i*CFG_XLEN + j)(0)      <= '0';
      end generate y_0;

      y_non_0 : if (i /= 0) generate
        -- North port is connected
        noc1_data_n_in(i*CFG_XLEN + j)       <= noc1_data_s_out((i-1)*CFG_XLEN + j);
        noc1_data_void_in(i*CFG_XLEN + j)(0) <= noc1_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc1_stop_in(i*CFG_XLEN + j)(0)      <= noc1_stop_out((i-1)*CFG_XLEN + j)(1);
        noc2_data_n_in(i*CFG_XLEN + j)       <= noc2_data_s_out((i-1)*CFG_XLEN + j);
        noc2_data_void_in(i*CFG_XLEN + j)(0) <= noc2_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc2_stop_in(i*CFG_XLEN + j)(0)      <= noc2_stop_out((i-1)*CFG_XLEN + j)(1);
        noc3_data_n_in(i*CFG_XLEN + j)       <= noc3_data_s_out((i-1)*CFG_XLEN + j);
        noc3_data_void_in(i*CFG_XLEN + j)(0) <= noc3_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc3_stop_in(i*CFG_XLEN + j)(0)      <= noc3_stop_out((i-1)*CFG_XLEN + j)(1);
        noc4_data_n_in(i*CFG_XLEN + j)       <= noc4_data_s_out((i-1)*CFG_XLEN + j);
        noc4_data_void_in(i*CFG_XLEN + j)(0) <= noc4_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc4_stop_in(i*CFG_XLEN + j)(0)      <= noc4_stop_out((i-1)*CFG_XLEN + j)(1);
        noc5_data_n_in(i*CFG_XLEN + j)       <= noc5_data_s_out((i-1)*CFG_XLEN + j);
        noc5_data_void_in(i*CFG_XLEN + j)(0) <= noc5_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc5_stop_in(i*CFG_XLEN + j)(0)      <= noc5_stop_out((i-1)*CFG_XLEN + j)(1);
        noc6_data_n_in(i*CFG_XLEN + j)       <= noc6_data_s_out((i-1)*CFG_XLEN + j);
        noc6_data_void_in(i*CFG_XLEN + j)(0) <= noc6_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc6_stop_in(i*CFG_XLEN + j)(0)      <= noc6_stop_out((i-1)*CFG_XLEN + j)(1);
      end generate y_non_0;

      y_YLEN : if (i = CFG_YLEN-1) generate
        -- South port is unconnected
        noc1_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc1_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc1_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc2_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc2_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc2_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc3_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc3_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc3_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc4_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc4_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc4_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc5_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc5_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc5_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc6_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc6_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc6_stop_in(i*CFG_XLEN + j)(1)      <= '0';
      end generate y_YLEN;

      y_non_YLEN : if (i /= CFG_YLEN-1) generate
        -- south port is connected
        noc1_data_s_in(i*CFG_XLEN + j)       <= noc1_data_n_out((i+1)*CFG_XLEN + j);
        noc1_data_void_in(i*CFG_XLEN + j)(1) <= noc1_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc1_stop_in(i*CFG_XLEN + j)(1)      <= noc1_stop_out((i+1)*CFG_XLEN + j)(0);
        noc2_data_s_in(i*CFG_XLEN + j)       <= noc2_data_n_out((i+1)*CFG_XLEN + j);
        noc2_data_void_in(i*CFG_XLEN + j)(1) <= noc2_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc2_stop_in(i*CFG_XLEN + j)(1)      <= noc2_stop_out((i+1)*CFG_XLEN + j)(0);
        noc3_data_s_in(i*CFG_XLEN + j)       <= noc3_data_n_out((i+1)*CFG_XLEN + j);
        noc3_data_void_in(i*CFG_XLEN + j)(1) <= noc3_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc3_stop_in(i*CFG_XLEN + j)(1)      <= noc3_stop_out((i+1)*CFG_XLEN + j)(0);
        noc4_data_s_in(i*CFG_XLEN + j)       <= noc4_data_n_out((i+1)*CFG_XLEN + j);
        noc4_data_void_in(i*CFG_XLEN + j)(1) <= noc4_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc4_stop_in(i*CFG_XLEN + j)(1)      <= noc4_stop_out((i+1)*CFG_XLEN + j)(0);
        noc5_data_s_in(i*CFG_XLEN + j)       <= noc5_data_n_out((i+1)*CFG_XLEN + j);
        noc5_data_void_in(i*CFG_XLEN + j)(1) <= noc5_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc5_stop_in(i*CFG_XLEN + j)(1)      <= noc5_stop_out((i+1)*CFG_XLEN + j)(0);
        noc6_data_s_in(i*CFG_XLEN + j)       <= noc6_data_n_out((i+1)*CFG_XLEN + j);
        noc6_data_void_in(i*CFG_XLEN + j)(1) <= noc6_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc6_stop_in(i*CFG_XLEN + j)(1)      <= noc6_stop_out((i+1)*CFG_XLEN + j)(0);
      end generate y_non_YLEN;

      x_0 : if (j = 0) generate
        -- West port is unconnected
        noc1_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc1_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc1_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc2_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc2_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc2_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc3_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc3_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc3_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc4_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc4_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc4_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc5_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc5_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc5_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc6_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc6_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc6_stop_in(i*CFG_XLEN + j)(2)      <= '0';
      end generate x_0;

      x_non_0 : if (j /= 0) generate
        -- West port is connected
        noc1_data_w_in(i*CFG_XLEN + j)       <= noc1_data_e_out(i*CFG_XLEN + j - 1);
        noc1_data_void_in(i*CFG_XLEN + j)(2) <= noc1_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc1_stop_in(i*CFG_XLEN + j)(2)      <= noc1_stop_out(i*CFG_XLEN + j - 1)(3);
        noc2_data_w_in(i*CFG_XLEN + j)       <= noc2_data_e_out(i*CFG_XLEN + j - 1);
        noc2_data_void_in(i*CFG_XLEN + j)(2) <= noc2_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc2_stop_in(i*CFG_XLEN + j)(2)      <= noc2_stop_out(i*CFG_XLEN + j - 1)(3);
        noc3_data_w_in(i*CFG_XLEN + j)       <= noc3_data_e_out(i*CFG_XLEN + j - 1);
        noc3_data_void_in(i*CFG_XLEN + j)(2) <= noc3_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc3_stop_in(i*CFG_XLEN + j)(2)      <= noc3_stop_out(i*CFG_XLEN + j - 1)(3);
        noc4_data_w_in(i*CFG_XLEN + j)       <= noc4_data_e_out(i*CFG_XLEN + j - 1);
        noc4_data_void_in(i*CFG_XLEN + j)(2) <= noc4_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc4_stop_in(i*CFG_XLEN + j)(2)      <= noc4_stop_out(i*CFG_XLEN + j - 1)(3);
        noc5_data_w_in(i*CFG_XLEN + j)       <= noc5_data_e_out(i*CFG_XLEN + j - 1);
        noc5_data_void_in(i*CFG_XLEN + j)(2) <= noc5_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc5_stop_in(i*CFG_XLEN + j)(2)      <= noc5_stop_out(i*CFG_XLEN + j - 1)(3);
        noc6_data_w_in(i*CFG_XLEN + j)       <= noc6_data_e_out(i*CFG_XLEN + j - 1);
        noc6_data_void_in(i*CFG_XLEN + j)(2) <= noc6_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc6_stop_in(i*CFG_XLEN + j)(2)      <= noc6_stop_out(i*CFG_XLEN + j - 1)(3);
      end generate x_non_0;

      x_XLEN : if (j = CFG_XLEN-1) generate
        -- East port is unconnected
        noc1_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc1_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc1_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc2_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc2_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc2_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc3_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc3_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc3_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc4_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc4_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc4_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc5_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc5_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc5_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc6_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc6_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc6_stop_in(i*CFG_XLEN + j)(3)      <= '0';
      end generate x_XLEN;

      x_non_XLEN : if (j /= CFG_XLEN-1) generate
        -- East port is connected
        noc1_data_e_in(i*CFG_XLEN + j)       <= noc1_data_w_out(i*CFG_XLEN + j + 1);
        noc1_data_void_in(i*CFG_XLEN + j)(3) <= noc1_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc1_stop_in(i*CFG_XLEN + j)(3)      <= noc1_stop_out(i*CFG_XLEN + j + 1)(2);
        noc2_data_e_in(i*CFG_XLEN + j)       <= noc2_data_w_out(i*CFG_XLEN + j + 1);
        noc2_data_void_in(i*CFG_XLEN + j)(3) <= noc2_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc2_stop_in(i*CFG_XLEN + j)(3)      <= noc2_stop_out(i*CFG_XLEN + j + 1)(2);
        noc3_data_e_in(i*CFG_XLEN + j)       <= noc3_data_w_out(i*CFG_XLEN + j + 1);
        noc3_data_void_in(i*CFG_XLEN + j)(3) <= noc3_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc3_stop_in(i*CFG_XLEN + j)(3)      <= noc3_stop_out(i*CFG_XLEN + j + 1)(2);
        noc4_data_e_in(i*CFG_XLEN + j)       <= noc4_data_w_out(i*CFG_XLEN + j + 1);
        noc4_data_void_in(i*CFG_XLEN + j)(3) <= noc4_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc4_stop_in(i*CFG_XLEN + j)(3)      <= noc4_stop_out(i*CFG_XLEN + j + 1)(2);
        noc5_data_e_in(i*CFG_XLEN + j)       <= noc5_data_w_out(i*CFG_XLEN + j + 1);
        noc5_data_void_in(i*CFG_XLEN + j)(3) <= noc5_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc5_stop_in(i*CFG_XLEN + j)(3)      <= noc5_stop_out(i*CFG_XLEN + j + 1)(2);
        noc6_data_e_in(i*CFG_XLEN + j)       <= noc6_data_w_out(i*CFG_XLEN + j + 1);
        noc6_data_void_in(i*CFG_XLEN + j)(3) <= noc6_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc6_stop_in(i*CFG_XLEN + j)(3)      <= noc6_stop_out(i*CFG_XLEN + j + 1)(2);
      end generate x_non_XLEN;

    end generate meshgen_x;
  end generate meshgen_y;

  router_gen : for i in 0 to CFG_TILES_NUM - 1 generate
    noc_domain_socket_i : noc_domain_socket
      generic map (
        this_has_token_pm => 0,
        is_tile_io        => is_io_tile(i),
        SIMULATION        => SIMULATION,
        ROUTER_PORTS      => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
        HAS_SYNC          => 1)
      port map (
        rst                     => reset_int,
        noc_clk_lock            => noc_clk_lock,
        tile_rstn               => tile_rstn(i),
        noc_clk                 => noc_clk,
        tile_clk                => tile_clk(i),
        noc_rstn                => noc_rstn(i),
        raw_rstn                => raw_rstn(i),
        acc_clk                 => open,
        -- DCO config
        dco_freq_sel            => dco_freq_sel(i),
        dco_div_sel             => dco_div_sel(i),
        dco_fc_sel              => dco_fc_sel(i),
        dco_cc_sel              => dco_cc_sel(i),
        dco_clk_sel             => dco_clk_sel(i),
        dco_en                  => dco_en(i),
        dco_clk_delay_sel       => dco_clk_delay_sel(i),
        -- pad config
        pad_cfg                 => pad_cfg(i),
        -- NoC
        noc1_data_n_in          => noc1_data_n_in(i),
        noc1_data_s_in          => noc1_data_s_in(i),
        noc1_data_w_in          => noc1_data_w_in(i),
        noc1_data_e_in          => noc1_data_e_in(i),
        noc1_data_void_in       => noc1_data_void_in(i),
        noc1_stop_in            => noc1_stop_in(i),
        noc1_data_n_out         => noc1_data_n_out(i),
        noc1_data_s_out         => noc1_data_s_out(i),
        noc1_data_w_out         => noc1_data_w_out(i),
        noc1_data_e_out         => noc1_data_e_out(i),
        noc1_data_void_out      => noc1_data_void_out(i),
        noc1_stop_out           => noc1_stop_out(i),
        noc2_data_n_in          => noc2_data_n_in(i),
        noc2_data_s_in          => noc2_data_s_in(i),
        noc2_data_w_in          => noc2_data_w_in(i),
        noc2_data_e_in          => noc2_data_e_in(i),
        noc2_data_void_in       => noc2_data_void_in(i),
        noc2_stop_in            => noc2_stop_in(i),
        noc2_data_n_out         => noc2_data_n_out(i),
        noc2_data_s_out         => noc2_data_s_out(i),
        noc2_data_w_out         => noc2_data_w_out(i),
        noc2_data_e_out         => noc2_data_e_out(i),
        noc2_data_void_out      => noc2_data_void_out(i),
        noc2_stop_out           => noc2_stop_out(i),
        noc3_data_n_in          => noc3_data_n_in(i),
        noc3_data_s_in          => noc3_data_s_in(i),
        noc3_data_w_in          => noc3_data_w_in(i),
        noc3_data_e_in          => noc3_data_e_in(i),
        noc3_data_void_in       => noc3_data_void_in(i),
        noc3_stop_in            => noc3_stop_in(i),
        noc3_data_n_out         => noc3_data_n_out(i),
        noc3_data_s_out         => noc3_data_s_out(i),
        noc3_data_w_out         => noc3_data_w_out(i),
        noc3_data_e_out         => noc3_data_e_out(i),
        noc3_data_void_out      => noc3_data_void_out(i),
        noc3_stop_out           => noc3_stop_out(i),
        noc4_data_n_in          => noc4_data_n_in(i),
        noc4_data_s_in          => noc4_data_s_in(i),
        noc4_data_w_in          => noc4_data_w_in(i),
        noc4_data_e_in          => noc4_data_e_in(i),
        noc4_data_void_in       => noc4_data_void_in(i),
        noc4_stop_in            => noc4_stop_in(i),
        noc4_data_n_out         => noc4_data_n_out(i),
        noc4_data_s_out         => noc4_data_s_out(i),
        noc4_data_w_out         => noc4_data_w_out(i),
        noc4_data_e_out         => noc4_data_e_out(i),
        noc4_data_void_out      => noc4_data_void_out(i),
        noc4_stop_out           => noc4_stop_out(i),
        noc5_data_n_in          => noc5_data_n_in(i),
        noc5_data_s_in          => noc5_data_s_in(i),
        noc5_data_w_in          => noc5_data_w_in(i),
        noc5_data_e_in          => noc5_data_e_in(i),
        noc5_data_void_in       => noc5_data_void_in(i),
        noc5_stop_in            => noc5_stop_in(i),
        noc5_data_n_out         => noc5_data_n_out(i),
        noc5_data_s_out         => noc5_data_s_out(i),
        noc5_data_w_out         => noc5_data_w_out(i),
        noc5_data_e_out         => noc5_data_e_out(i),
        noc5_data_void_out      => noc5_data_void_out(i),
        noc5_stop_out           => noc5_stop_out(i),
        noc6_data_n_in          => noc6_data_n_in(i),
        noc6_data_s_in          => noc6_data_s_in(i),
        noc6_data_w_in          => noc6_data_w_in(i),
        noc6_data_e_in          => noc6_data_e_in(i),
        noc6_data_void_in       => noc6_data_void_in(i),
        noc6_stop_in            => noc6_stop_in(i),
        noc6_data_n_out         => noc6_data_n_out(i),
        noc6_data_s_out         => noc6_data_s_out(i),
        noc6_data_w_out         => noc6_data_w_out(i),
        noc6_data_e_out         => noc6_data_e_out(i),
        noc6_data_void_out      => noc6_data_void_out(i),
        noc6_stop_out           => noc6_stop_out(i),
        -- monitors
        mon_noc                 => mon_noc(i),
  	acc_activity            => '0',
        LDOCTRL                 => ldo_ctrl(i),
        -- synchronizers out to tile
        noc1_output_port_tile   => noc1_data_l_out(i),
        noc1_data_void_out_tile => noc1_data_void_out_tile(i),
        noc1_stop_in_tile       => noc1_stop_in_tile(i),
        noc2_output_port_tile   => noc2_data_l_out(i),
        noc2_data_void_out_tile => noc2_data_void_out_tile(i),
        noc2_stop_in_tile       => noc2_stop_in_tile(i),
        noc3_output_port_tile   => noc3_data_l_out(i),
        noc3_data_void_out_tile => noc3_data_void_out_tile(i),
        noc3_stop_in_tile       => noc3_stop_in_tile(i),
        noc4_output_port_tile   => noc4_data_l_out(i),
        noc4_data_void_out_tile => noc4_data_void_out_tile(i),
        noc4_stop_in_tile       => noc4_stop_in_tile(i),
        noc5_output_port_tile   => noc5_data_l_out(i),
        noc5_data_void_out_tile => noc5_data_void_out_tile(i),
        noc5_stop_in_tile       => noc5_stop_in_tile(i),
        noc6_output_port_tile   => noc6_data_l_out(i),
        noc6_data_void_out_tile => noc6_data_void_out_tile(i),
        noc6_stop_in_tile       => noc6_stop_in_tile(i),
        -- tile to synchronizers in
        noc1_input_port_tile    => noc1_data_l_in(i),
        noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
        noc1_stop_out_tile      => noc1_stop_out_tile(i),
        noc2_input_port_tile    => noc2_data_l_in(i),
        noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
        noc2_stop_out_tile      => noc2_stop_out_tile(i),
        noc3_input_port_tile    => noc3_data_l_in(i),
        noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
        noc3_stop_out_tile      => noc3_stop_out_tile(i),
        noc4_input_port_tile    => noc4_data_l_in(i),
        noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
        noc4_stop_out_tile      => noc4_stop_out_tile(i),
        noc5_input_port_tile    => noc5_data_l_in(i),
        noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
        noc5_stop_out_tile      => noc5_stop_out_tile(i),
        noc6_input_port_tile    => noc6_data_l_in(i),
        noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
        noc6_stop_out_tile      => noc6_stop_out_tile(i));
  
  end generate router_gen;

  -----------------------------------------------------------------------------
  -- TILES
  -----------------------------------------------------------------------------
  tiles_gen : for i in 0 to CFG_TILES_NUM - 1 generate

    empty_tile : if tile_type(i) = 0 generate
      tile_empty_i : asic_tile_empty
        generic map (
          SIMULATION   => SIMULATION,
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => CFG_CLK_STR,
          HAS_SYNC     => CFG_SYNC_EN)
        port map (
          rst                     => reset_int,
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          ext_clk                 => noc_clk,
          clk_div                 => clk_div_int(i),
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          -- Noc interface
          noc1_stop_in_tile       => noc1_stop_in_tile(i),
          noc1_stop_out_tile      => noc1_stop_out_tile(i),
          noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
          noc1_data_void_out_tile => noc1_data_void_out_tile(i),
          noc2_stop_in_tile       => noc2_stop_in_tile(i),
          noc2_stop_out_tile      => noc2_stop_out_tile(i),
          noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
          noc2_data_void_out_tile => noc2_data_void_out_tile(i),
          noc3_stop_in_tile       => noc3_stop_in_tile(i),
          noc3_stop_out_tile      => noc3_stop_out_tile(i),
          noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
          noc3_data_void_out_tile => noc3_data_void_out_tile(i),
          noc4_stop_in_tile       => noc4_stop_in_tile(i),
          noc4_stop_out_tile      => noc4_stop_out_tile(i),
          noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
          noc4_data_void_out_tile => noc4_data_void_out_tile(i),
          noc5_stop_in_tile       => noc5_stop_in_tile(i),
          noc5_stop_out_tile      => noc5_stop_out_tile(i),
          noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
          noc5_data_void_out_tile => noc5_data_void_out_tile(i),
          noc6_stop_in_tile       => noc6_stop_in_tile(i),
          noc6_stop_out_tile      => noc6_stop_out_tile(i),
          noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
          noc6_data_void_out_tile => noc6_data_void_out_tile(i),
          noc1_input_port_tile    => noc1_data_l_in(i), 
          noc2_input_port_tile    => noc2_data_l_in(i), 
          noc3_input_port_tile    => noc3_data_l_in(i), 
          noc4_input_port_tile    => noc4_data_l_in(i), 
          noc5_input_port_tile    => noc5_data_l_in(i), 
          noc6_input_port_tile    => noc6_data_l_in(i), 
          noc1_output_port_tile   => noc1_data_l_out(i),
          noc2_output_port_tile   => noc2_data_l_out(i),
          noc3_output_port_tile   => noc3_data_l_out(i),
          noc4_output_port_tile   => noc4_data_l_out(i),
          noc5_output_port_tile   => noc5_data_l_out(i),
          noc6_output_port_tile   => noc6_data_l_out(i),
          mon_noc                 => mon_noc(i));
    end generate empty_tile;


    cpu_tile : if tile_type(i) = 1 generate
-- pragma translate_off
      assert tile_cpu_id(i) /= -1 report "Undefined CPU ID for CPU tile" severity error;
-- pragma translate_on
      tile_cpu_i : asic_tile_cpu
        generic map (
          SIMULATION   => SIMULATION,
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => CFG_CLK_STR,
          HAS_SYNC     => CFG_SYNC_EN)
        port map (
          rst                     => reset_int,
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          ext_clk                 => noc_clk,
          clk_div                 => clk_div_int(i),
          cpuerr                  => cpuerr_vec(tile_cpu_id(i)),
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          -- Noc interface
          noc1_stop_in_tile       => noc1_stop_in_tile(i),
          noc1_stop_out_tile      => noc1_stop_out_tile(i),
          noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
          noc1_data_void_out_tile => noc1_data_void_out_tile(i),
          noc2_stop_in_tile       => noc2_stop_in_tile(i),
          noc2_stop_out_tile      => noc2_stop_out_tile(i),
          noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
          noc2_data_void_out_tile => noc2_data_void_out_tile(i),
          noc3_stop_in_tile       => noc3_stop_in_tile(i),
          noc3_stop_out_tile      => noc3_stop_out_tile(i),
          noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
          noc3_data_void_out_tile => noc3_data_void_out_tile(i),
          noc4_stop_in_tile       => noc4_stop_in_tile(i),
          noc4_stop_out_tile      => noc4_stop_out_tile(i),
          noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
          noc4_data_void_out_tile => noc4_data_void_out_tile(i),
          noc5_stop_in_tile       => noc5_stop_in_tile(i),
          noc5_stop_out_tile      => noc5_stop_out_tile(i),
          noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
          noc5_data_void_out_tile => noc5_data_void_out_tile(i),
          noc6_stop_in_tile       => noc6_stop_in_tile(i),
          noc6_stop_out_tile      => noc6_stop_out_tile(i),
          noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
          noc6_data_void_out_tile => noc6_data_void_out_tile(i),
          noc1_input_port_tile    => noc1_data_l_in(i), 
          noc2_input_port_tile    => noc2_data_l_in(i), 
          noc3_input_port_tile    => noc3_data_l_in(i), 
          noc4_input_port_tile    => noc4_data_l_in(i), 
          noc5_input_port_tile    => noc5_data_l_in(i), 
          noc6_input_port_tile    => noc6_data_l_in(i), 
          noc1_output_port_tile   => noc1_data_l_out(i),
          noc2_output_port_tile   => noc2_data_l_out(i),
          noc3_output_port_tile   => noc3_data_l_out(i),
          noc4_output_port_tile   => noc4_data_l_out(i),
          noc5_output_port_tile   => noc5_data_l_out(i),
          noc6_output_port_tile   => noc6_data_l_out(i),
          mon_noc                 => mon_noc(i));
    end generate cpu_tile;


    accelerator_tile : if tile_type(i) = 2 generate
-- pragma translate_off
      assert tile_device(i) /= 0 report "Undefined device ID for accelerator tile" severity error;
-- pragma translate_on
      tile_acc_i : asic_tile_acc
        generic map (
          SIMULATION        => SIMULATION,
          this_hls_conf     => tile_design_point(i),
          this_device       => tile_device(i),
          this_irq_type     => tile_irq_type(i),
          this_has_l2       => tile_has_l2(i),
          this_has_token_pm => tile_has_tdvfs(i),
          ROUTER_PORTS      => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco      => CFG_CLK_STR,
          HAS_SYNC          => CFG_SYNC_EN)
        port map (
          rst                     => reset_int,
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          ext_clk                 => noc_clk,
          clk_div                 => clk_div_int(i),
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          LDOCTRL                 => ldo_ctrl(i),
          -- Noc interface
          noc1_stop_in_tile       => noc1_stop_in_tile(i),
          noc1_stop_out_tile      => noc1_stop_out_tile(i),
          noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
          noc1_data_void_out_tile => noc1_data_void_out_tile(i),
          noc2_stop_in_tile       => noc2_stop_in_tile(i),
          noc2_stop_out_tile      => noc2_stop_out_tile(i),
          noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
          noc2_data_void_out_tile => noc2_data_void_out_tile(i),
          noc3_stop_in_tile       => noc3_stop_in_tile(i),
          noc3_stop_out_tile      => noc3_stop_out_tile(i),
          noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
          noc3_data_void_out_tile => noc3_data_void_out_tile(i),
          noc4_stop_in_tile       => noc4_stop_in_tile(i),
          noc4_stop_out_tile      => noc4_stop_out_tile(i),
          noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
          noc4_data_void_out_tile => noc4_data_void_out_tile(i),
          noc5_stop_in_tile       => noc5_stop_in_tile(i),
          noc5_stop_out_tile      => noc5_stop_out_tile(i),
          noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
          noc5_data_void_out_tile => noc5_data_void_out_tile(i),
          noc6_stop_in_tile       => noc6_stop_in_tile(i),
          noc6_stop_out_tile      => noc6_stop_out_tile(i),
          noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
          noc6_data_void_out_tile => noc6_data_void_out_tile(i),
          noc1_input_port_tile    => noc1_data_l_in(i),  
          noc2_input_port_tile    => noc2_data_l_in(i),  
          noc3_input_port_tile    => noc3_data_l_in(i),  
          noc4_input_port_tile    => noc4_data_l_in(i),  
          noc5_input_port_tile    => noc5_data_l_in(i),  
          noc6_input_port_tile    => noc6_data_l_in(i),  
          noc1_output_port_tile   => noc1_data_l_out(i),
          noc2_output_port_tile   => noc2_data_l_out(i),
          noc3_output_port_tile   => noc3_data_l_out(i),
          noc4_output_port_tile   => noc4_data_l_out(i),
          noc5_output_port_tile   => noc5_data_l_out(i),
          noc6_output_port_tile   => noc6_data_l_out(i),
            mon_noc                 => mon_noc(i));
    end generate accelerator_tile;


    io_tile : if tile_type(i) = 3 generate
      tile_io_i : asic_tile_io
        generic map (
          SIMULATION   => SIMULATION,
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => CFG_CLK_STR,
          HAS_SYNC     => CFG_SYNC_EN)
        port map (
          rst                     => reset_int,       -- from I/O PAD reset
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          noc_clk_out             => noc_clk,         -- NoC clock out
          noc_clk_lock_out        => noc_clk_lock,
          ext_clk_noc             => ext_clk_int,     -- backup NoC clock
          clk_div_noc             => clk_div_noc_int,
          ext_clk                 => noc_clk,  -- backup clock (fixed)
          clk_div                 => clk_div_int(i),
          reset_o2                => reset_o2_int,
          etx_clk                 => etx_clk_int,
          erx_clk                 => erx_clk_int,
          erxd                    => erxd_int,
          erx_dv                  => erx_dv_int,
          erx_er                  => erx_er_int,
          erx_col                 => erx_col_int,
          erx_crs                 => erx_crs_int,
          etxd                    => etxd_int,
          etx_en                  => etx_en_int,
          etx_er                  => etx_er_int,
          emdc                    => emdc_int,
          emdio_i                 => emdio_i,
          emdio_o                 => emdio_o,
          emdio_oe                => emdio_oe,
          iolink_data_oen         => iolink_data_oen,
          iolink_data_in          => iolink_data_in_int,
          iolink_data_out         => iolink_data_out_int,
          iolink_valid_in         => iolink_valid_in_int,
          iolink_valid_out        => iolink_valid_out_int,
          iolink_clk_in           => iolink_clk_in_int,
          iolink_clk_out          => iolink_clk_out_int,
          iolink_credit_in        => iolink_credit_in_int,
          iolink_credit_out       => iolink_credit_out_int,
          uart_rxd                => uart_rxd_int,
          uart_txd                => uart_txd_int,
          uart_ctsn               => uart_ctsn_int,
          uart_rtsn               => uart_rtsn_int,
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          -- Noc interface
          noc1_stop_in_tile       => noc1_stop_in_tile(i),
          noc1_stop_out_tile      => noc1_stop_out_tile(i),
          noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
          noc1_data_void_out_tile => noc1_data_void_out_tile(i),
          noc2_stop_in_tile       => noc2_stop_in_tile(i),
          noc2_stop_out_tile      => noc2_stop_out_tile(i),
          noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
          noc2_data_void_out_tile => noc2_data_void_out_tile(i),
          noc3_stop_in_tile       => noc3_stop_in_tile(i),
          noc3_stop_out_tile      => noc3_stop_out_tile(i),
          noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
          noc3_data_void_out_tile => noc3_data_void_out_tile(i),
          noc4_stop_in_tile       => noc4_stop_in_tile(i),
          noc4_stop_out_tile      => noc4_stop_out_tile(i),
          noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
          noc4_data_void_out_tile => noc4_data_void_out_tile(i),
          noc5_stop_in_tile       => noc5_stop_in_tile(i),
          noc5_stop_out_tile      => noc5_stop_out_tile(i),
          noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
          noc5_data_void_out_tile => noc5_data_void_out_tile(i),
          noc6_stop_in_tile       => noc6_stop_in_tile(i),
          noc6_stop_out_tile      => noc6_stop_out_tile(i),
          noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
          noc6_data_void_out_tile => noc6_data_void_out_tile(i),
          noc1_input_port_tile    => noc1_data_l_in(i),  
          noc2_input_port_tile    => noc2_data_l_in(i),  
          noc3_input_port_tile    => noc3_data_l_in(i),  
          noc4_input_port_tile    => noc4_data_l_in(i),  
          noc5_input_port_tile    => noc5_data_l_in(i),  
          noc6_input_port_tile    => noc6_data_l_in(i),  
          noc1_output_port_tile   => noc1_data_l_out(i),
          noc2_output_port_tile   => noc2_data_l_out(i),
          noc3_output_port_tile   => noc3_data_l_out(i),
          noc4_output_port_tile   => noc4_data_l_out(i),
          noc5_output_port_tile   => noc5_data_l_out(i),
          noc6_output_port_tile   => noc6_data_l_out(i),
          mon_noc                 => mon_noc(i));
    end generate io_tile;


    mem_tile : if tile_type(i) = 4 generate
      tile_mem_i : asic_tile_mem
        generic map (
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => CFG_CLK_STR,
          HAS_SYNC     => CFG_SYNC_EN)
        port map (
          rst                     => reset_int,
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          ext_clk                 => noc_clk,
          clk_div                 => clk_div_int(i),
          fpga_data_in            => fpga_data_in((tile_mem_id(i) + 1) * (CFG_MEM_LINK_BITS) - 1 downto tile_mem_id(i) * (CFG_MEM_LINK_BITS)),
          fpga_data_out           => fpga_data_out((tile_mem_id(i) + 1) * (CFG_MEM_LINK_BITS) - 1 downto tile_mem_id(i) * (CFG_MEM_LINK_BITS)),
          fpga_oen                => fpga_oen(tile_mem_id(i)),
          fpga_valid_in           => fpga_valid_in_int(tile_mem_id(i)),
          fpga_valid_out          => fpga_valid_out_int(tile_mem_id(i)),
          fpga_clk_in             => fpga_clk_in_int(tile_mem_id(i)),
          fpga_clk_out            => fpga_clk_out_int(tile_mem_id(i)),
          fpga_credit_in          => fpga_credit_in_int(tile_mem_id(i)),
          fpga_credit_out         => fpga_credit_out_int(tile_mem_id(i)),
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          dco_clk_delay_sel       => dco_clk_delay_sel(i),
          -- Noc interface
          noc1_stop_in_tile       => noc1_stop_in_tile(i),
          noc1_stop_out_tile      => noc1_stop_out_tile(i),
          noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
          noc1_data_void_out_tile => noc1_data_void_out_tile(i),
          noc2_stop_in_tile       => noc2_stop_in_tile(i),
          noc2_stop_out_tile      => noc2_stop_out_tile(i),
          noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
          noc2_data_void_out_tile => noc2_data_void_out_tile(i),
          noc3_stop_in_tile       => noc3_stop_in_tile(i),
          noc3_stop_out_tile      => noc3_stop_out_tile(i),
          noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
          noc3_data_void_out_tile => noc3_data_void_out_tile(i),
          noc4_stop_in_tile       => noc4_stop_in_tile(i),
          noc4_stop_out_tile      => noc4_stop_out_tile(i),
          noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
          noc4_data_void_out_tile => noc4_data_void_out_tile(i),
          noc5_stop_in_tile       => noc5_stop_in_tile(i),
          noc5_stop_out_tile      => noc5_stop_out_tile(i),
          noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
          noc5_data_void_out_tile => noc5_data_void_out_tile(i),
          noc6_stop_in_tile       => noc6_stop_in_tile(i),
          noc6_stop_out_tile      => noc6_stop_out_tile(i),
          noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
          noc6_data_void_out_tile => noc6_data_void_out_tile(i),
          noc1_input_port_tile    => noc1_data_l_in(i),  
          noc2_input_port_tile    => noc2_data_l_in(i),  
          noc3_input_port_tile    => noc3_data_l_in(i),  
          noc4_input_port_tile    => noc4_data_l_in(i),  
          noc5_input_port_tile    => noc5_data_l_in(i),  
          noc6_input_port_tile    => noc6_data_l_in(i),  
          noc1_output_port_tile   => noc1_data_l_out(i),
          noc2_output_port_tile   => noc2_data_l_out(i),
          noc3_output_port_tile   => noc3_data_l_out(i),
          noc4_output_port_tile   => noc4_data_l_out(i),
          noc5_output_port_tile   => noc5_data_l_out(i),
          noc6_output_port_tile   => noc6_data_l_out(i),
          mon_noc                 => mon_noc(i));
    end generate mem_tile;

    slm_tile : if tile_type(i) = 5 generate
      tile_slm_i : asic_tile_slm
        generic map (
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => CFG_CLK_STR,
          HAS_SYNC     => CFG_SYNC_EN)
        port map (
          rst                     => reset_int,
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          ext_clk                 => noc_clk,
          clk_div                 => clk_div_int(i),
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          dco_clk_delay_sel       => dco_clk_delay_sel(i),
          -- Noc interface
          noc1_stop_in_tile       => noc1_stop_in_tile(i),
          noc1_stop_out_tile      => noc1_stop_out_tile(i),
          noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
          noc1_data_void_out_tile => noc1_data_void_out_tile(i),
          noc2_stop_in_tile       => noc2_stop_in_tile(i),
          noc2_stop_out_tile      => noc2_stop_out_tile(i),
          noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
          noc2_data_void_out_tile => noc2_data_void_out_tile(i),
          noc3_stop_in_tile       => noc3_stop_in_tile(i),
          noc3_stop_out_tile      => noc3_stop_out_tile(i),
          noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
          noc3_data_void_out_tile => noc3_data_void_out_tile(i),
          noc4_stop_in_tile       => noc4_stop_in_tile(i),
          noc4_stop_out_tile      => noc4_stop_out_tile(i),
          noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
          noc4_data_void_out_tile => noc4_data_void_out_tile(i),
          noc5_stop_in_tile       => noc5_stop_in_tile(i),
          noc5_stop_out_tile      => noc5_stop_out_tile(i),
          noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
          noc5_data_void_out_tile => noc5_data_void_out_tile(i),
          noc6_stop_in_tile       => noc6_stop_in_tile(i),
          noc6_stop_out_tile      => noc6_stop_out_tile(i),
          noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
          noc6_data_void_out_tile => noc6_data_void_out_tile(i),
          noc1_input_port_tile    => noc1_data_l_in(i),  
          noc2_input_port_tile    => noc2_data_l_in(i),  
          noc3_input_port_tile    => noc3_data_l_in(i),  
          noc4_input_port_tile    => noc4_data_l_in(i),  
          noc5_input_port_tile    => noc5_data_l_in(i),  
          noc6_input_port_tile    => noc6_data_l_in(i),  
          noc1_output_port_tile   => noc1_data_l_out(i),
          noc2_output_port_tile   => noc2_data_l_out(i),
          noc3_output_port_tile   => noc3_data_l_out(i),
          noc4_output_port_tile   => noc4_data_l_out(i),
          noc5_output_port_tile   => noc5_data_l_out(i),
          noc6_output_port_tile   => noc6_data_l_out(i),
          mon_noc                 => mon_noc(i));
    end generate slm_tile;

  end generate tiles_gen;

end;
