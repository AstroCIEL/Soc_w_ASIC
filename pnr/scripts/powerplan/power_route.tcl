#####################################################################################
# Description:  Innovus Power Routing Script
# Modifier:	    Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

# route power structures
# connect:                  connect the specified objects to rings and stripes, possible value: blockPin | corePin | padPin | padRing | floatingStripe | secondaryPowerPin
# nets:                     specify the names of the nets to connect
# layerChangeRange:         allow routing between the specified bottom-most and top-most layer
# crossoverViaLayerRange:   specify the highest and lowest layer that can be used for via stacking at the crossover point between power structures
# targetViaLayerRange:      specify the highest and lowest layer that can be used for via stacking at a target
# allowJogging:             specify that jogs allowed during routing to avoid DRC violations, possible value: 0 | 1
# allowLayerChange:         allow connections to target on different layers, possible value: 0 | 1
# deleteExistingRoutes:     specify that the software remove existing connections when using sroute command multiple times
sroute 	-connect                    { corePin } \
        -nets                       { VDD VSS } \
        -layerChangeRange           { M1 M6 } \
        -crossoverViaLayerRange     { M1 M6 } \
        -targetViaLayerRange        { M1 M6 } \
        -allowJogging               0 \
        -allowLayerChange           1 \
        -checkAlignedSecondaryPin   1 \
        -deleteExistingRoutes

# modify or delete existing power vias or add new power vias
# skip_via_on_pin:          prevent vias from being generated on the specified types of pins, possible value: Pad | Block | Cover | Standardcell | Physicalpin
# skip_via_on_wire_shape:   prevent vias from being generated for the specified wire shapes, possible value: Blockring | Stripe | Followpin | Corewire | Blockwire | Iowire | Padring | Ring | Fillwire | Noshape
# bottom_layer:             specify the lowest layer to which vias can connect
# top_layer:                specify the highest layer to which vias can connect
# add_vias:                 when set to 1, add power vias, possible value: 0 | 1, cannot be set concurrently with `delete_vias`
# delete_vias:              when set to 1, delete power vias, possible value: 0 | 1, cannot be set concurrently with `add_vias`
# modify_vias:              modify vias in the design, possible value: 0 | 1
editPowerVia    -skip_via_on_pin    Standardcell \
                -bottom_layer       M1 \
                -top_layer          M6 \
                -add_vias           1

verify_drc

# get an idea of zero wire load timing & power of the design
timeDesign  -outDir ../${rm_core_top}/reports/postPowerplan \
            -expandedViews \
            -prePlace
report_power -o     ../${rm_core_top}/reports/postPowerplan \
             -view  func_tt_0p80v_25c
exec ../scripts/extract_report.csh ../${rm_core_top}/reports/postPowerplan

