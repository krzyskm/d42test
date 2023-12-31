/*
 - Name: Device Connectivity
 - Purpose: Query that exports the current devices with connections.
 - Date Created: 10/01/20
 - Changes:
  4/15/21
   - change device_v1 and hardware_v1 to device_v2 and hardware_v2
*/
select
    d.name "Device Name"
    ,hp.hwaddress "Host MAC Address"
    ,hp.port "Host Port"
    ,sp.port "Switch Port"
    ,sp.hwaddress "Switch MAC Address"
    ,s.name "Switch Name"
    ,v.number "VLAN"
from
    view_device_v2 d
    join view_netport_v1 hp on hp.device_fk =  d.device_pk
    join view_netport_v1 sp on (sp.netport_pk = hp.remote_netport_fk or sp.remote_netport_fk = hp.netport_pk)
    join view_device_v2 s on s.device_pk = sp.device_fk and s.network_device = 't'
    left join view_vlan_on_netport_v1 vp on vp.netport_fk = sp.netport_pk
    left join view_vlan_v1 v on v.vlan_pk = vp.vlan_fk
    left join view_hardware_v2 hws on hws.hardware_pk = s.hardware_fk
    left join view_hardware_v2 hw on hw.hardware_pk = d.hardware_fk
    left join view_device_v2 hv on d.virtual_host_device_fk = hv.device_pk
    left join view_devices_in_cluster_v1 c on c.child_device_fk = coalesce(hv.device_pk, case when d.blade_slot_no <> '' then d.device_pk end)
where d.network_device = 'f' and s.name <> ''
order by d.name ASC