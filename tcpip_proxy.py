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

from scapy.layers.l2 import Ether
from scapy.all import * # pyright: ignore[reportWildcardImportFromLibrary]

class TCPIPProxy:
    def __init__(self, target_ip: str, target_port: int, src_ip: str = "0.0.0.0", src_port: int = 9999, DEBUG_MODE = False):
        """
        You can use a tcp connection with an ethernet frame. 
        For now simple http requests that fit in one frame will work, 
        the response _should_ be as long as it is.

        Args:
            target_ip (str): Re-routed destination.
            target_port (int): Re-routed destination port.
        """

        self.__target_ip = target_ip
        self.__target_port = target_port
        self.__src_ip = src_ip
        self.__src_port = src_port
        self.__sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.__debug_mode = DEBUG_MODE

        self.__data_packets = []

    def open_connection(self):
        """ Connects to the target host by using TCP socket. """

        if self.__debug_mode: print("try to connect", self.__target_ip, self.__target_port)
        self.__sock.connect((self.__target_ip, self.__target_port))
        if self.__debug_mode: print("The connection is opened to the host:", self.__target_ip, self.__target_port)

    def close_connection(self):
        self.__sock.close()
        if self.__debug_mode: print("The connection is closed.")

    def __send_data(self, data):
        self.__sock.sendall(data)
        if self.__debug_mode: print("The data was sent.")

    def __receive_data(self):
        if self.__debug_mode: print("Receiving...")
        while True:
            part = self.__sock.recv(64)
            self.__data_packets.append(part)
            if len(part) < 64:  # if less than 64 bytes are received, it's likely the end of the transmission
                break
        if self.__debug_mode: print("The response reveived successfully.")
        return self.__data_packets

    def __process_ethernet_frame(self, frame: bytes):
        """ Parses TCP payload of ethernet frame. """

        eth = Ether(frame)
        if eth.haslayer(IP):  # type: ignore
            ip = eth[IP]  # type: ignore
            if ip.haslayer(TCP):  # type: ignore
                tcp = ip[TCP]  # type: ignore
                return bytes(tcp.payload)
        return None

    def __create_ethernet_frame(self, ip_src: str, ip_dst: str, tcp_payload: bytes):
        eth = Ether()/IP(src=ip_src, dst=ip_dst)/TCP(dport=self.__target_port)/tcp_payload # type: ignore
        return bytes(eth)
    
    def create_frame(self, ip_src: str, ip_dst: str, tcp_payload: bytes):
        return self.__create_ethernet_frame(ip_src, ip_dst, tcp_payload)

    def send_frame(self, frame: bytes) -> list[bytes] | None:
        """ 
        Sends ethernet frame to the ethernet network. 
        Also waits the response and returns it.
        """

        tcp_data = self.__process_ethernet_frame(frame)
        if tcp_data:
            if self.__debug_mode: print("Sending", tcp_data)
            self.__send_data(tcp_data)
            packets = self.__receive_data()
            frames = []
            for packet in packets:
                frame = self.__create_ethernet_frame(self.__src_ip, self.__target_ip, packet)
                frames.append(frame)
            if self.__debug_mode: print("The response", frames)
            return frames
            
