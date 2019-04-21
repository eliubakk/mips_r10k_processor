`ifndef __CACHE_DEFS_VH__
`define __CACHE_DEFS_VH__

//`ifndef NUM_WAYS
`define NUM_WAYS 4
//`endif

`define NUM_SETS (32/`NUM_WAYS)
`define NUM_SET_BITS $clog2(`NUM_SETS)
`define NUM_TAG_BITS (13-`NUM_SET_BITS)

typedef struct packed {
  logic [63:0] data;
  logic [(`NUM_TAG_BITS-1):0] tag;
  logic valid;
  logic dirty;
} CACHE_LINE_T;

const CACHE_LINE_T EMPTY_CACHE_LINE = 
{
  64'b0,
  {`NUM_TAG_BITS{1'b0}},
  1'b0,
  1'b0
};

typedef struct packed {
  CACHE_LINE_T [(`NUM_WAYS-1):0] cache_lines;
} CACHE_SET_T;


typedef struct packed {
  logic [`NUM_TAG_BITS-1:0] tag;
  logic [`NUM_SET_BITS-1:0] idx;
  logic [63:0] data;
  logic valid;
  logic dirty;
} DCACHE_FIFO_T;

const DCACHE_FIFO_T EMPTY_DCACHE =
{
  {`NUM_TAG_BITS{1'b0}},
  {`NUM_SET_BITS{1'b0}},
  64'b0,
  1'b0
};

typedef struct packed {
  CACHE_LINE_T line;
  logic [(`NUM_SET_BITS-1):0] idx;
} VIC_CACHE_T;

const VIC_CACHE_T EMPTY_VIC_CACHE = 
{
  EMPTY_CACHE_LINE,
  {`NUM_SET_BITS{1'b0}}
};

typedef struct packed {
  logic [63:0] address;
  logic [63:0] data;
  logic valid;
} RETIRE_BUF_T;

const RETIRE_BUF_T EMPTY_RETIRE_BUF =
{
  64'b0,
  64'b0,
  1'b0
};

`endif