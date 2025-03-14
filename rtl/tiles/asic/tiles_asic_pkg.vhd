-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.monitor_pkg.all;
use work.esp_noc_csr_pkg.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.ahb2mig_7series_pkg.all;
use work.socmap.all;

package tiles_asic_pkg is

  component asic_tile_cpu is
    generic (
      SIMULATION   : boolean;
      HAS_SYNC     : integer range 0 to 1 := 1;
      ROUTER_PORTS : ports_vec;
      this_has_dco : integer range 0 to 2);
    port (
      rst                : in  std_ulogic;
      raw_rstn           : in  std_ulogic;
      noc_rstn           : in  std_ulogic;
      tile_rstn          : out std_ulogic;  
      tile_clk           : out std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      cpuerr             : out std_ulogic;
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      -- Noc interface
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc                 : in  monitor_noc_vector(1 to 6));
  end component asic_tile_cpu;

  component asic_tile_acc is
    generic (
      SIMULATION        : boolean := false;
      this_hls_conf     : hlscfg_t;
      this_device       : devid_t;
      this_irq_type     : integer;
      this_has_l2       : integer range 0 to 1;
      this_has_token_pm : integer range 0 to 1;
      HAS_SYNC : integer range 0 to 1 := 1;
      ROUTER_PORTS      : ports_vec;
      this_has_dco : integer range 0 to 2);
    port (
      rst                : in  std_ulogic;
      raw_rstn           : in  std_ulogic;
      noc_rstn           : in  std_ulogic;
      tile_rstn          : out std_ulogic;  
      tile_clk           : out std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      LDOCTRL           : in std_logic_vector(7 downto 0);
      -- Noc interface
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc                 : in  monitor_noc_vector(1 to 6));
  end component asic_tile_acc;

  component asic_tile_mem is
    generic (
      SIMULATION   : boolean := false;
      ROUTER_PORTS : ports_vec;
      HAS_SYNC     : integer range 0 to 1 := 1;
      this_has_dco : integer range 0 to 2 := 0);
    port (
      rst                : in    std_ulogic;
      raw_rstn           : in  std_ulogic;
      noc_rstn           : in  std_ulogic;
      tile_rstn          : out std_ulogic;  
      tile_clk           : out std_ulogic;
      ext_clk            : in    std_ulogic;
      clk_div            : out   std_ulogic;
      fpga_data_in       : in    std_logic_vector(CFG_MEM_LINK_BITS - 1 downto 0);
      fpga_data_out      : out   std_logic_vector(CFG_MEM_LINK_BITS - 1 downto 0);
      fpga_oen           : out   std_ulogic;
      fpga_valid_in      : in    std_ulogic;
      fpga_valid_out     : out   std_ulogic;
      fpga_clk_in        : in    std_ulogic;
      fpga_clk_out       : out   std_ulogic;
      fpga_credit_in     : in    std_ulogic;
      fpga_credit_out    : out   std_ulogic;
      tdi                : in    std_logic;
      tdo                : out   std_logic;
      tms                : in    std_logic;
      tclk               : in    std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      dco_clk_delay_sel : in std_logic_vector(11 downto 0);
      -- Noc interface
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc                 : in  monitor_noc_vector(1 to 6));
  end component asic_tile_mem;

  component asic_tile_io is
    generic (
      SIMULATION   : boolean;
      HAS_SYNC     : integer range 0 to 1 := 1;
      ROUTER_PORTS : ports_vec;
      this_has_dco : integer range 0 to 2);
    port (
      rst                : in  std_ulogic;
      noc_clk_out        : out std_ulogic;
      raw_rstn           : in  std_ulogic;
      noc_rstn           : in  std_ulogic;
      tile_rstn          : out std_ulogic;  
      tile_clk           : out std_ulogic;
      noc_clk_lock_out   : out std_ulogic;
      ext_clk_noc        : in  std_ulogic;
      clk_div_noc        : out std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      reset_o2           : out std_ulogic;
      etx_clk            : in  std_ulogic;
      erx_clk            : in  std_ulogic;
      erxd               : in  std_logic_vector(3 downto 0);
      erx_dv             : in  std_ulogic;
      erx_er             : in  std_ulogic;
      erx_col            : in  std_ulogic;
      erx_crs            : in  std_ulogic;
      etxd               : out std_logic_vector(3 downto 0);
      etx_en             : out std_ulogic;
      etx_er             : out std_ulogic;
      emdc               : out std_ulogic;
      emdio_i            : in  std_ulogic;
      emdio_o            : out std_ulogic;
      emdio_oe           : out std_ulogic;
      uart_rxd           : in  std_ulogic;
      uart_txd           : out std_ulogic;
      uart_ctsn          : in  std_ulogic;
      uart_rtsn          : out std_ulogic;
      -- I/O link
      iolink_data_oen    : out std_logic;
      iolink_data_in     : in  std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_data_out    : out std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_valid_in    : in  std_ulogic;
      iolink_valid_out   : out std_ulogic;
      iolink_clk_in      : in  std_ulogic;
      iolink_clk_out     : out std_ulogic;
      iolink_credit_in   : in  std_ulogic;
      iolink_credit_out  : out std_ulogic;
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      -- Noc interface
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc                 : in  monitor_noc_vector(1 to 6));
  end component asic_tile_io;

  component asic_tile_empty is
    generic (
      SIMULATION   : boolean; 
      HAS_SYNC     : integer range 0 to 1 := 1;
      ROUTER_PORTS : ports_vec;
      this_has_dco : integer range 0 to 2);
    port (
      rst                : in  std_logic;
      raw_rstn           : in  std_ulogic;
      noc_rstn           : in  std_ulogic;
      tile_rstn          : out std_ulogic;  
      tile_clk           : out std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
  
      -- Noc interface
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc                 : in  monitor_noc_vector(1 to 6));
  end component asic_tile_empty;

  component asic_tile_slm is
    generic (
      SIMULATION   : boolean := false;
      HAS_SYNC     : integer range 0 to 1 := 1;
      ROUTER_PORTS : ports_vec;
      this_has_dco : integer range 0 to 2);
    port (
      rst                : in  std_ulogic;
      raw_rstn           : in  std_ulogic;
      noc_rstn           : in  std_ulogic;
      tile_rstn          : out std_ulogic;  
      tile_clk           : out std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      dco_clk_delay_sel : in std_logic_vector(11 downto 0);
  
      -- Noc interface
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc                 : in  monitor_noc_vector(1 to 6));
  end component asic_tile_slm;

  component asic_tile_slm_ddr is
    generic (
      SIMULATION   : boolean := false;
      ROUTER_PORTS : ports_vec;
      this_has_dco : integer range 0 to 2;
      HAS_SYNC     : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      raw_rstn           : in  std_ulogic;
      noc_rstn           : in  std_ulogic;
      tile_rstn          : out std_ulogic;  
      tile_clk           : out std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      lpddr_o_calib_done : out std_ulogic;
      lpddr_o_ck_p       : out std_logic;
      lpddr_o_ck_n       : out std_logic;
      lpddr_o_cke        : out std_logic;
      lpddr_o_ba         : out std_logic_vector(2 downto 0);
      lpddr_o_addr       : out std_logic_vector(15 downto 0);
      lpddr_o_cs_n       : out std_logic;
      lpddr_o_ras_n      : out std_logic;
      lpddr_o_cas_n      : out std_logic;
      lpddr_o_we_n       : out std_logic;
      lpddr_o_reset_n    : out std_logic;
      lpddr_o_odt        : out std_logic;
      lpddr_o_dm_oen     : out std_logic_vector(3 downto 0);
      lpddr_o_dm         : out std_logic_vector(3 downto 0);
      lpddr_o_dqs_p_oen  : out std_logic_vector(3 downto 0);
      lpddr_o_dqs_p_ien  : out std_logic_vector(3 downto 0);
      lpddr_o_dqs_p_o    : out std_logic_vector(3 downto 0);
      lpddr_o_dqs_n_oen  : out std_logic_vector(3 downto 0);
      lpddr_o_dqs_n_ien  : out std_logic_vector(3 downto 0);
      lpddr_o_dqs_n_o    : out std_logic_vector(3 downto 0);
      lpddr_o_dq_oen     : out std_logic_vector(31 downto 0);
      lpddr_o_dq_o       : out std_logic_vector(31 downto 0);
      lpddr_i_dqs_p_i    : in  std_logic_vector(3 downto 0);
      lpddr_i_dqs_n_i    : in  std_logic_vector(3 downto 0);
      lpddr_i_dq_i       : in  std_logic_vector(31 downto 0);
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- DCO config
      dco_en            : in std_ulogic;
      dco_clk_sel       : in std_ulogic;
      dco_cc_sel        : in std_logic_vector(5 downto 0);
      dco_fc_sel        : in std_logic_vector(5 downto 0);
      dco_div_sel       : in std_logic_vector(2 downto 0);
      dco_freq_sel      : in std_logic_vector(1 downto 0);
      dco_clk_delay_sel : in std_logic_vector(11 downto 0);
      -- NoC interface
      noc1_stop_in_tile       : out std_ulogic;
      noc1_stop_out_tile      : in  std_ulogic;
      noc1_data_void_in_tile  : out std_ulogic;
      noc1_data_void_out_tile : in  std_ulogic;
      noc2_stop_in_tile       : out std_ulogic;
      noc2_stop_out_tile      : in  std_ulogic;
      noc2_data_void_in_tile  : out std_ulogic;
      noc2_data_void_out_tile : in  std_ulogic;
      noc3_stop_in_tile       : out std_ulogic;
      noc3_stop_out_tile      : in  std_ulogic;
      noc3_data_void_in_tile  : out std_ulogic;
      noc3_data_void_out_tile : in  std_ulogic;
      noc4_stop_in_tile       : out std_ulogic;
      noc4_stop_out_tile      : in  std_ulogic;
      noc4_data_void_in_tile  : out std_ulogic;
      noc4_data_void_out_tile : in  std_ulogic;
      noc5_stop_in_tile       : out std_ulogic;
      noc5_stop_out_tile      : in  std_ulogic;
      noc5_data_void_in_tile  : out std_ulogic;
      noc5_data_void_out_tile : in  std_ulogic;
      noc6_stop_in_tile       : out std_ulogic;
      noc6_stop_out_tile      : in  std_ulogic;
      noc6_data_void_in_tile  : out std_ulogic;
      noc6_data_void_out_tile : in  std_ulogic;
      noc1_input_port_tile    : out coh_noc_flit_type;
      noc2_input_port_tile    : out coh_noc_flit_type;
      noc3_input_port_tile    : out coh_noc_flit_type;
      noc4_input_port_tile    : out dma_noc_flit_type;
      noc5_input_port_tile    : out misc_noc_flit_type;
      noc6_input_port_tile    : out dma_noc_flit_type;
      noc1_output_port_tile   : in  coh_noc_flit_type;
      noc2_output_port_tile   : in  coh_noc_flit_type;
      noc3_output_port_tile   : in  coh_noc_flit_type;
      noc4_output_port_tile   : in  dma_noc_flit_type;
      noc5_output_port_tile   : in  misc_noc_flit_type;
      noc6_output_port_tile   : in  dma_noc_flit_type;
      mon_noc                 : in  monitor_noc_vector(1 to 6));
  end component asic_tile_slm_ddr;

end tiles_asic_pkg;
