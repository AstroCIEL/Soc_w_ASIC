// Single-Port SRAM (synthesizable core, with simulation-only file I/O).
// One read/write port shared between writes and reads on each cycle.
// On a write cycle (cen=0, wen=1): mem[addr] <= din, dout reflects din next cycle.
// On a read  cycle (cen=0, wen=0): dout <= mem[addr] next cycle.
//
// The synthesizable subset is the mem array + the clocked read/write logic.
// File-based initialization (INIT_FILE) and memory dump (DUMP_FILE) are
// preserved as simulation-only features and are wrapped in
// `synopsys translate_off/on` markers so that synthesis tools ignore them
// (the inferred SRAM/register file relies on runtime writes via the wen port).

module sp_sram #(
    parameter int    DATA_WIDTH       = 128,
    parameter int    ADDR_WIDTH       = 9,
    parameter string INIT_FILE        = "",
    parameter int    INIT_TOKEN_WIDTH = DATA_WIDTH,
    parameter string DUMP_FILE        = "",
    parameter int    DUMP_START       = 0,
    parameter int    DUMP_COUNT       = (1 << ADDR_WIDTH)
) (
    input  logic                  clk,
    input  logic                  cen,    // chip enable, active low
    input  logic                  wen,    // write enable, active high (1=write, 0=read)
    input  logic                  dump_i,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    localparam int DEPTH = 1 << ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Power-on reset of the storage array. Synthesis tools either map this to
    // a power-on reset of the inferred register file or ignore it entirely
    // for hard SRAM macros.
    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            mem[i] = '0;
        end
    end

    // synopsys translate_off
    // Simulation-only initialization from a hex token file. Stripped during
    // synthesis; LUT contents are loaded at runtime via the write port.
    localparam int TOKENS_PER_WORD_INIT = DATA_WIDTH / INIT_TOKEN_WIDTH;
    initial begin : init_mem
        int fd;
        int scan_status;
        int word_idx;
        int token_idx;
        logic [INIT_TOKEN_WIDTH-1:0] token;
        logic [DATA_WIDTH-1:0] word;

        if (INIT_TOKEN_WIDTH <= 0 || DATA_WIDTH % INIT_TOKEN_WIDTH != 0) begin
            $fatal(1, "sp_sram: DATA_WIDTH (%0d) must be divisible by INIT_TOKEN_WIDTH (%0d)",
                   DATA_WIDTH, INIT_TOKEN_WIDTH);
        end

        if (INIT_FILE != "") begin
            fd = $fopen(INIT_FILE, "r");
            if (fd == 0) begin
                $fatal(1, "sp_sram: failed to open INIT_FILE %s", INIT_FILE);
            end

            word_idx = 0;
            token_idx = 0;
            word = '0;

            while (!$feof(fd)) begin
                scan_status = $fscanf(fd, "%h", token);
                if (scan_status == 1) begin
                    if (word_idx >= DEPTH) begin
                        $fatal(1, "sp_sram: INIT_FILE %s has more data than DEPTH %0d", INIT_FILE, DEPTH);
                    end

                    word[token_idx * INIT_TOKEN_WIDTH +: INIT_TOKEN_WIDTH] = token;
                    token_idx++;

                    if (token_idx == TOKENS_PER_WORD_INIT) begin
                        mem[word_idx] = word;
                        word_idx++;
                        token_idx = 0;
                        word = '0;
                    end
                end else if (scan_status == -1) begin
                    break;
                end else begin
                    void'($fgetc(fd));
                end
            end

            if (token_idx != 0) begin
                $fatal(1, "sp_sram: INIT_FILE %s ends with an incomplete word (%0d/%0d tokens)",
                       INIT_FILE, token_idx, TOKENS_PER_WORD_INIT);
            end

            $fclose(fd);
        end
    end
    // synopsys translate_on

    // Synthesizable single-port SRAM access.
    always @(posedge clk) begin
        if (!cen) begin
            if (wen) begin
                mem[addr] <= din;
                dout      <= din;
            end else begin
                dout <= mem[addr];
            end
        end
    end

    // synopsys translate_off
    // Simulation-only memory dump task; stripped during synthesis.
    always @(posedge clk) begin
        if (dump_i && DUMP_FILE != "") begin
            dump_mem_to_file();
        end
    end

    task automatic dump_mem_to_file;
        int fd;
        int dump_end;
        int tokens_per_word_dump;
        begin
            tokens_per_word_dump = DATA_WIDTH / INIT_TOKEN_WIDTH;

            fd = $fopen(DUMP_FILE, "w");
            if (fd == 0) begin
                $fatal(1, "sp_sram: failed to open DUMP_FILE %s", DUMP_FILE);
            end

            dump_end = DUMP_START + DUMP_COUNT;
            if (dump_end > DEPTH) begin
                dump_end = DEPTH;
            end

            for (int word_idx = DUMP_START; word_idx < dump_end; word_idx++) begin
                for (int token_idx = 0; token_idx < tokens_per_word_dump; token_idx++) begin
                    if (token_idx != 0) begin
                        $fwrite(fd, "  ");
                    end
                    if (INIT_TOKEN_WIDTH == 16) begin
                        $fwrite(fd, "%04h", mem[word_idx][token_idx * INIT_TOKEN_WIDTH +: INIT_TOKEN_WIDTH]);
                    end else if (INIT_TOKEN_WIDTH == 8) begin
                        $fwrite(fd, "%02h", mem[word_idx][token_idx * INIT_TOKEN_WIDTH +: INIT_TOKEN_WIDTH]);
                    end else begin
                        $fwrite(fd, "%0h", mem[word_idx][token_idx * INIT_TOKEN_WIDTH +: INIT_TOKEN_WIDTH]);
                    end
                end
                $fwrite(fd, "\n");
            end

            $fclose(fd);
        end
    endtask
    // synopsys translate_on

endmodule
