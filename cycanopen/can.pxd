from libc.stdint cimport *

cdef extern from "linux/can.h":

    # controller area network (CAN) kernel definitions

    # special address description flags for the CAN_ID
    int CAN_EFF_FLAG # 0x80000000U # EFF/SFF is set in the MSB
    int CAN_RTR_FLAG # 0x40000000U # remote transmission request
    int CAN_ERR_FLAG # 0x20000000U # error message frame

    # valid bits in CAN ID for frame formats 
    int CAN_SFF_MASK # 0x000007FFU # standard frame format (SFF)
    int CAN_EFF_MASK # 0x1FFFFFFFU # extended frame format (EFF)
    int CAN_ERR_MASK # 0x1FFFFFFFU # omit EFF, RTR, ERR flags

    #
    #  Controller Area Network Identifier structure
    # 
    #  bit 0-28	: CAN identifier (11/29 bit)
    #  bit 29	: error message frame flag (0 = data frame, 1 = error message)
    #  bit 30	: remote transmission request flag (1 = rtr frame)
    #  bit 31	: frame format flag (0 = standard 11 bit, 1 = extended 29 bit)

#    ctypedef uint32_t canid_t

    int CAN_SFF_ID_BITS	#	11
    int CAN_EFF_ID_BITS	#	29

    #
    #  Controller Area Network Error Message Frame Mask structure
    # 
    #  bit 0-28	: error class mask (see include/linux/can/error.h)
    #  bit 29-31	: set to zero
#    ctypedef uint32_t can_err_mask_t


    # CAN payload length and DLC definitions according to ISO 11898-1 */
    int CAN_MAX_DLC #8
    int CAN_MAX_DLEN #8

    # CAN FD payload length and DLC definitions according to ISO 11898-7 */
    int CANFD_MAX_DLC #15
    int CANFD_MAX_DLEN #64

    #  struct can_frame - basic CAN frame structure
    #  @can_id:  CAN ID of the frame and CAN_*_FLAG flags, see canid_t definition
    #  @can_dlc: frame payload length in byte (0 .. 8) aka data length code
    #            N.B. the DLC field from ISO 11898-1 Chapter 8.4.2.3 has a 1:1
    #            mapping of the 'data length code' to the real payload length
    #  @data:    CAN frame payload (up to 8 byte)

    cdef struct can_frame:
        uint32_t can_id  # 32 bit CAN_ID + EFF/RTR/ERR flags */
        uint8_t can_dlc # frame payload length in byte (0 .. CAN_MAX_DLEN) */
        uint8_t *data   #[CAN_MAX_DLEN] __attribute__((aligned(8)))

    #
    #  defined bits for canfd_frame.flags
    # 
    #  The use of struct canfd_frame implies the Extended Data Length (EDL) bit to
    #  be set in the CAN frame bitstream on the wire. The EDL bit switch turns
    #  the CAN controllers bitstream processor into the CAN FD mode which creates
    #  two new options within the CAN FD frame specification:
    # 
    #  Bit Rate Switch - to indicate a second bitrate is/was used for the payload
    #  Error State Indicator - represents the error state of the transmitting node
    # 
    #  As the CANFD_ESI bit is internally generated by the transmitting CAN
    #  controller only the CANFD_BRS bit is relevant for real CAN controllers when
    #  building a CAN FD frame for transmission. Setting the CANFD_ESI bit can make
    #  sense for virtual CAN interfaces to test applications with echoed frames.

    int CANFD_BRS # 0x01 # bit rate switch (second bitrate for payload data) */
    int CANFD_ESI # 0x02 # error state indicator of the transmitting node */


    #  struct canfd_frame - CAN flexible data rate frame structure
    #  @can_id: CAN ID of the frame and CAN_*_FLAG flags, see canid_t definition
    #  @len:    frame payload length in byte (0 .. CANFD_MAX_DLEN)
    #  @flags:  additional flags for CAN FD
    #  @__res0: reserved / padding
    #  @__res1: reserved / padding
    #  @data:   CAN FD frame payload (up to CANFD_MAX_DLEN byte)

    cdef struct canfd_frame:
        uint32_t can_id  # 32 bit CAN_ID + EFF/RTR/ERR flags */
        uint8_t    len     # frame payload length in byte */
        uint8_t    flags   # additional flags for CAN FD */
        uint8_t    __res0  # reserved / padding */
        uint8_t    __res1  # reserved / padding */
        uint8_t   *data  # [CANFD_MAX_DLEN] __attribute__((aligned(8)))


    int CAN_MTU		# (sizeof(struct can_frame))
    int CANFD_MTU	# (sizeof(struct canfd_frame))

    # particular protocols of the protocol family PF_CAN */
    int CAN_RAW		#1 # RAW sockets */
    int CAN_BCM		#2 # Broadcast Manager */
    int CAN_TP16	#3 # VAG Transport Protocol v1.6 */
    int CAN_TP20	#4 # VAG Transport Protocol v2.0 */
    int CAN_MCNET	#5 # Bosch MCNet */
    int CAN_ISOTP	#6 # ISO 15765-2 Transport Protocol */
    int CAN_NPROTO	#7

    int SOL_CAN_BASE #100

    #  struct sockaddr_can - the sockaddr structure for CAN sockets
    #  @can_family:  address family number AF_CAN.
    #  @can_ifindex: CAN network interface index.
    #  @can_addr:    protocol specific address information
    # /
    # struct sockaddr_can {
    # 	__kernel_sa_family_t can_family
    # 	int         can_ifindex
    # 	union {
    # 		# transport protocol class address information (e.g. ISOTP) */
    # 		struct { canid_t rx_id, tx_id } tp

    # 		# reserved for future CAN protocols address information */
    # 	} can_addr
    # }

    #  struct can_filter - CAN ID based filter in can_register().
    #  @can_id:   relevant bits of CAN ID which are not masked out.
    #  @can_mask: CAN mask (see description)
    # 
    #  Description:
    #  A filter matches, when
    # 
    #           <received_can_id> & mask == can_id & mask
    # 
    #  The filter can be inverted (CAN_INV_FILTER bit set in can_id) or it can
    #  filter for error message frames (CAN_ERR_FLAG bit set in mask).
    # 
    cdef struct can_filter:
        uint32_t can_id
        uint32_t can_mask

    int CAN_INV_FILTER # 0x20000000U # to be set in can_filter.can_id */
