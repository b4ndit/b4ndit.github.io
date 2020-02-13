---
layout: post
title: CARP Conflict with VRRP
date: '2018-09-17 14:41:37'
---

We utilize two pfSenses in CARP-failover mode as the firewalls protecting a Hyper-V cluster. This past weekend at 3am, the firewalls started experiencing high packet loss to the upstream gateway.

The problem, as it turns out, was that the upstream provider migrated us to new switching infrastructure that utilized VRRP instead of HSRP for their failover. VRRP and CARP happen to both share the same MAC address scheme for their shared virtual IPs. These MAC addresses can be changed, and the conflict resolved, by setting the VRID (for VRRP) or the VHID (for CARP) to a unique number. The VRID and VHID setting determines the last octet of the MAC address (e.g. 00:00:5E:00:01:XX).

If you happen to be experiencing this problem on pfSense, you can read more about troubleshooting it [here](https://www.netgate.com/docs/pfsense/highavailability/troubleshooting-high-availability-clusters.html).

