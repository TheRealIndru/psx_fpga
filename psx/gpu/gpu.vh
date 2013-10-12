
/* Defines the number of pixels a single pipeline stage processes at once */
`define GPU_PIPELINE_WIDTH 32

/* CMD struct */
typedef struct packed {
   logic [9:0]                      x0, x1, x2;
   logic [9:0] 			    y0, y1, y2;
   logic [7:0] 			    r0, g0, b0;
   logic [7:0] 			    r1, g1, b1;
   logic [7:0] 			    r2, g2, b2;
   logic [7:0] 			    u0, u1, u2; // Texture page coords
   logic [7:0] 			    v0, v1, v2; //    "     "     "
   logic [15:0] 		    clut;
   logic [15:0] 		    text_page;
   enum logic {TRI, RECT, LINE}     shape;
   enum logic {SEMI, OPAQ}          transparency;
   enum logic {GOURAUD, FLAT, NONE} shade;
   enum logic {TEXT, MONO}          texture;
   enum logic {BLEND, RAW}          texture_mode;
} CMD_t;
   

/* GPU Status register struct */
typedef struct packed {
   logic       interlaced_parity;
   logic [1:0] DMA_direction;
   logic       DMA_rdy;
   logic       VRAM2CPU_rdy;
   logic       CMD_rdy;
   logic       DMA_fifo_state;
   logic       irq;
   logic       display_en;
   logic       interlaced;
   logic       depth;
   logic       video_mode;
   logic       vertical_res;
   logic [1:0] horizontal_res_1;
   logic       horizontal_res_2;
   logic       text_en;
   logic       reverse;
   logic       reserved;
   logic       mask_en;
   logic       set_mask;
   logic       draw_to_display;
   logic       dither_mode;
   logic [1:0] text_mode;
   logic [1:0] semi_trans_mode;
   logic       text_y;
   logic [3:0] text_x;
} GPU_status_t;

/* Draw Stage barrier regs */
typedef struct packed {
   logic                                   valid;
   logic [`GPU_PIPELINE_WIDTH-1:0][9:0]    x;
   logic [`GPU_PIPELINE_WIDTH-1:0][9:0]    y;
} drawing_stage_t;

/* Color Stage barrier regs */
typedef struct packed {
   logic                                   valid;
   logic [`GPU_PIPELINE_WIDTH-1:0][9:0]    x;
   logic [`GPU_PIPELINE_WIDTH-1:0][9:0]    y;
   logic [`GPU_PIPELINE_WIDTH-1:0] 	   in_shape;
} color_stage_t;

/* Shade Stage barrier regs */
typedef struct packed {
   logic                                   valid;
   logic [`GPU_PIPELINE_WIDTH-1:0][9:0]    x;
   logic [`GPU_PIPELINE_WIDTH-1:0][9:0]    y;
   logic [`GPU_PIPELINE_WIDTH-1:0] 	   in_shape;
   logic [`GPU_PIPELINE_WIDTH-1:0][7:0]    r, g, b;
} shader_stage_t;

/* Writeback Stage barrier regs */
typedef struct packed {
   logic                                   valid;
   logic [`GPU_PIPELINE_WIDTH-1:0][9:0]    x;
   logic [`GPU_PIPELINE_WIDTH-1:0][9:0]    y;
   logic [`GPU_PIPELINE_WIDTH-1:0] 	   in_shape;
   logic [`GPU_PIPELINE_WIDTH-1:0][7:0]    r, g, b;
} wb_stage_t;
