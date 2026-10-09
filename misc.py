"""
Copyright (C) 2026 Matias Siro

This program is free software; you can redistribute it and/or modify 
it under the terms of the GNU General Public License as published by 
the Free Software Foundation; version 2.

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program; if not, write to the Free Software Foundation, Inc., 
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
"""

def bytes_to_str_ip_presentation(b: bytes) -> str:
    ret_str = ""
    for n in b:
        ret_str = ret_str + f"{int(n)}."
    return ret_str[:-1]

def parse_ethernet_frame(frame: bytes) -> list[str]:
    """ 
    Returns [src_ip, dst_ip, src_port, dst_port]. The return data assumes that the payload includes "noraml" IPv4 packet and it contains TCP packet as payload.
    """

    import dpkt

    eth = dpkt.ethernet.Ethernet(frame)
    ip = eth.data
    
    return [bytes_to_str_ip_presentation(ip.src), # type: ignore
            bytes_to_str_ip_presentation(ip.dst), # type: ignore
            str(ip.tcp.sport), # type: ignore
            str(ip.tcp.dport) # type: ignore
            ] 
