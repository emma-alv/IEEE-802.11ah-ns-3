/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * ns-2 simple.tcl script (ported from ns-2)
 * Originally authored by Steve McCanne, 12/19/1996
 */

// Port of ns-2/tcl/ex/simple.tcl to ns-3
//
// Network topology
//
//  n0
//     \ 5 Mb/s, 2ms
//      \          1.5Mb/s, 10ms
//       n2 -------------------------n3
//      /
//     / 5 Mb/s, 2ms
//   n1
//
// - all links are point-to-point links with indicated one-way BW/delay
// - CBR/UDP flows from n0 to n3, and from n3 to n1
// - FTP/TCP flow from n0 to n3, starting at time 1.2 to time 1.35 sec.
// - UDP packet size of 210 bytes, with per-packet interval 0.00375 sec.
//   (i.e., DataRate of 448,000 bps)
// - DropTail queues 
// - Tracing of queues and packet receptions to file 
//   "simple-error-model.tr"

#include <fstream>
#include "ns3/core-module.h"
#include "ns3/common-module.h"
#include "ns3/simulator-module.h"
#include "ns3/helper-module.h"
#include "ns3/global-route-manager.h"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("SimpleErrorModelExample");

int 
main (int argc, char *argv[])
{
  // Users may find it convenient to turn on explicit debugging
  // for selected modules; the below lines suggest how to do this
#if 0 
  LogComponentEnable ("SimplePointToPointExample", LOG_LEVEL_INFO);
#endif

  //
  // Make the random number generators generate reproducible results.
  //
  RandomVariable::UseGlobalSeed (1, 1, 2, 3, 5, 8);

  // Set a few parameters
  Config::SetDefault ("ns3::RateErrorModel::ErrorRate", Double (0.01));
  Config::SetDefault ("ns3::RateErrorModel::ErrorUnit", String ("EU_PKT"));
  
  Config::SetDefault ("ns3::OnOffApplication::PacketSize", Uinteger (210));
  Config::SetDefault ("ns3::OnOffApplication::DataRate", DataRate ("448kb/s"));


  // Allow the user to override any of the defaults and the above
  // Bind()s at run-time, via command-line arguments
  CommandLine cmd;
  cmd.Parse (argc, argv);

  // Here, we will explicitly create four nodes.  In more sophisticated
  // topologies, we could configure a node factory.
  NS_LOG_INFO ("Create nodes.");
  NodeContainer c;
  c.Create (4);
  NodeContainer n0n2 = NodeContainer (c.Get (0), c.Get (2));
  NodeContainer n1n2 = NodeContainer (c.Get (1), c.Get (2));
  NodeContainer n3n2 = NodeContainer (c.Get (3), c.Get (2));

  InternetStackHelper internet;
  internet.Build (c);

  // We create the channels first without any IP addressing information
  NS_LOG_INFO ("Create channels.");
  PointToPointHelper p2p;
  p2p.SetChannelParameter ("BitRate", DataRate (5000000));
  p2p.SetChannelParameter ("Delay", MilliSeconds (2));
  NetDeviceContainer d0d2 = p2p.Build (n0n2);

  NetDeviceContainer d1d2 = p2p.Build (n1n2);

  p2p.SetChannelParameter ("BitRate", DataRate (1500000));
  p2p.SetChannelParameter ("Delay", MilliSeconds (10));
  NetDeviceContainer d3d2 = p2p.Build (n3n2);
  
  // Later, we add IP addresses.  
  NS_LOG_INFO ("Assign IP Addresses.");
  Ipv4AddressHelper ipv4;
  ipv4.SetBase ("10.1.1.0", "255.255.255.0");
  ipv4.Allocate (d0d2);
  
  ipv4.SetBase ("10.1.2.0", "255.255.255.0");
  Ipv4InterfaceContainer i1i2 = ipv4.Allocate (d1d2);

  ipv4.SetBase ("10.1.3.0", "255.255.255.0");
  Ipv4InterfaceContainer i3i2 = ipv4.Allocate (d3d2);

  NS_LOG_INFO ("Use global routing.");
  GlobalRouteManager::PopulateRoutingTables ();

  // Create the OnOff application to send UDP datagrams of size
  // 210 bytes at a rate of 448 Kb/s
  NS_LOG_INFO ("Create Applications.");
  uint16_t port = 9;   // Discard port (RFC 863)
  OnOffHelper onoff;
  onoff.SetUdpRemote (i3i2.GetAddress (1), port);
  onoff.SetAppAttribute ("OnTime", ConstantVariable(1));
  onoff.SetAppAttribute ("OffTime", ConstantVariable(0));
  ApplicationContainer apps = onoff.Build (c.Get (0));
  apps.Start(Seconds(1.0));
  apps.Stop (Seconds(10.0));

  // Create an optional packet sink to receive these packets
  PacketSinkHelper sink;
  sink.SetupUdp (Ipv4Address::GetAny (), port);
  apps = sink.Build (c.Get (3));
  apps.Start (Seconds (1.0));
  apps.Stop (Seconds (10.0));

  // Create a similar flow from n3 to n1, starting at time 1.1 seconds
  onoff.SetUdpRemote (i1i2.GetAddress (0), port);
  apps = onoff.Build (c.Get (3));
  apps.Start(Seconds(1.1));
  apps.Stop (Seconds(10.0));

  // Create a packet sink to receive these packets
  sink.SetupUdp (Ipv4Address::GetAny (), port);
  apps = sink.Build (c.Get (1));
  apps.Start (Seconds (1.1));
  apps.Stop (Seconds (10.0));

  //
  // Error model
  //
  // Create an ErrorModel based on the implementation (constructor)
  // specified by the default classId
  Ptr<RateErrorModel> em = CreateObject<RateErrorModel> ("RanVar", UniformVariable (0.0, 1.0),
                                                         "ErrorRate", Double (0.001));
  d3d2.Get (0)->SetAttribute ("ReceiveErrorModel", em);

  // Now, let's use the ListErrorModel and explicitly force a loss
  // of the packets with pkt-uids = 11 and 17 on node 2, device 0
  std::list<uint32_t> sampleList;
  sampleList.push_back (11);
  sampleList.push_back (17);
  // This time, we'll explicitly create the error model we want
  Ptr<ListErrorModel> pem = CreateObject<ListErrorModel> ();
  pem->SetList (sampleList);
  d0d2.Get (1)->SetAttribute ("ReceiveErrorModel", pem);

  std::ofstream ascii;
  ascii.open ("simple-error-model.tr");
  PointToPointHelper::EnablePcap ("simple-error-model");
  PointToPointHelper::EnableAscii (ascii);

  NS_LOG_INFO ("Run Simulation.");
  Simulator::Run ();    
  Simulator::Destroy ();
  NS_LOG_INFO ("Done.");
}
