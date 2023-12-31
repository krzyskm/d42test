    /*
 - Name: All Devices
 - Purpose: An extensive query to report on all devices and majority of related objects/attributes.
 - Date Created: 10/01/20
 - Changes: 10/12/20 Updated to use new subtypes and view_device_v2 introduced in 16.19
*/
    select
        d.last_edited "Last_Discovered",
        d.device_pk "Device ID",
        d.name "Device_Name",
        ip.ip_address "IP_Address",
        d.tags "Tags",
        d.in_service "In Service",
        d.service_level "Service_Level",
        d.type "Device_Type",
        COALESCE(d.physicalsubtype, '') || COALESCE(d.virtualsubtype, '') "Device Subtype",
        d.serial_no "Device_Serial",
        d.virtual_host "Virtual Host",
        d.network_device "Network Device",
        d.os_architecture "OS Architecture",
        d.total_cpus "Total CPUs",
        d.core_per_cpu "Cores Per CPU",
        d.threads_per_core "Threads Per Core",
        d.cpu_speed "CPU Speed",
        d.total_cpus*d.core_per_cpu "Total Cores",
        d.ram "RAM",
        v2.name "OS Vendor",
        osc.category_name "OS Category",
        CASE d.os_version 
            WHEN '' then d.os_name
            ELSE coalesce(d.os_name || ' - ' || 
            d.os_version,d.os_name)
        END "OS Name",
        d.os_version "OS Version",
        d.os_version_no "OS Version Number",
        ose.eol "OS_End of Life",
	    ose.eos "OS_End of Support",
        v.name "Manufacturer",
        h.name "Hardware Model",
        d.asset_no "Asset Number",
(select count(*) from view_softwareinuse_v1 sd where sd.device_fk = d.device_pk) "Software Discovered",
(select count(*) from view_serviceinstance_v2 si where si.device_fk = d.device_pk) "Services Discovered",
(select count(*) from view_appcomp_v1 a where a.device_fk = d.device_pk) "Application Components Discovered",
(select count(*) from view_mountpoint_v1 m where m.device_fk = d.device_pk and m.fstype_name <> 'nfs' and m.fstype_name <> 'nfs4' and m.filesystem not like '\\\\%')"Local Disk Count",
(select count(*) from view_mountpoint_v1 mp where mp.device_fk = d.device_pk) "Mounts Discovered",
(select count(*) from view_ipaddress_v1 ip where ip.device_fk = d.device_pk) "IP Addresses Discovered",
(select count(*) from view_part_v1 p where p.device_fk = d.device_pk) "Parts Discovered",
        d.bios_version "BIOS Version",
        d.bios_revision "BIOS Revision",
        d.bios_release_date "BIOS Release Date",
        sr.name "Storage Room",
        b.name "Building Name",
        m.name "Room Name",
        r.row "Row Name",
        r.name "Rack Name",
        h.size "Size (RU)",
        (SELECT array_to_string(array(
                  select ns.name
                  from view_networkshare_v1 ns
                  where ns.device_fk = d.device_pk),
                  ' | ')) network_shares,
        (SELECT array_to_string(array(
                  select mp.filesystem
                  from view_mountpoint_v1 mp
                  where mp.device_fk = d.device_pk),
                  ' | ')) mount_points,
        ci.account,
        cv.name "Cloud Service Provider",
        ci.service_name "Cloud Service Name",
        ci.instance_id "Cloud Instance ID",
        ci.instance_name "Cloud Instance Name",
        ci.instance_type "Cloud Instance Type",
        ci.status "Cloud Instance Status",
        ci.location "Cloud Location",
        ci.notes "Cloud Notes",
        pch.po_date "PO Date",
        pch.cost "PO Cost",
        pli.cost "Line Item Cost",
        pch.order_no "Order Number",
        pch.cc_code "Cost Center",
        pch.cc_description "Cost Center Description",
        (SELECT array_to_string(array(
                      select ip.ip_address
                      from view_ipaddress_v1 ip
                      where ip.device_fk = d.device_pk),
                      ' | ')) all_listener_device_ips,
        (SELECT array_to_string(array(
                      select ip.label
                      from view_ipaddress_v1 ip
                      where ip.device_fk = d.device_pk),
                      ' | ')) all_labels,
       round(((select sum(m.capacity-m.free_capacity)/1024 from view_mountpoint_v1 m where m.device_fk = d.device_pk and m.fstype_name <> 'nfs' and m.fstype_name <> 'nfs4' and m.filesystem not like '\\\\%')), 2)"Used Space",
       round(((select sum(m.capacity/1024) from view_mountpoint_v1 m where m.device_fk = d.device_pk and m.fstype_name <> 'nfs' and m.fstype_name <> 'nfs4' and m.filesystem not like '\\\\%')), 2)"Total Space",
       round(((select sum(m.free_capacity/1024) from view_mountpoint_v1 m where m.device_fk = d.device_pk and m.fstype_name <> 'nfs' and m.fstype_name <> 'nfs4' and m.filesystem not like '\\\\%')), 2)"Total Free Space"
        from view_device_v2 d
        left join view_ipaddress_v1 ip on ip.device_fk = d.device_pk
        left join view_purchaselineitems_to_devices_v1 ptd on ptd.device_fk = d.device_pk
        left join view_purchaselineitem_v1 pli on ptd.purchaselineitem_fk = pli.purchaselineitem_pk
        left join view_purchase_v1 pch on pch.purchase_pk = pli.purchase_fk
        left join view_oseoleos_v1 ose on ose.os_fk = d.os_fk
        left join view_hardware_v1 h on d.hardware_fk = h.hardware_pk
        left join view_vendor_v1 v on h.vendor_fk = v.vendor_pk
        left join view_room_v1 sr on sr.room_pk = d.storage_room_fk 
        left join view_rack_v1 r on d.rack_fk = r.rack_pk
        left join view_room_v1 m on r.room_fk = m.room_pk
        left join view_building_v1 b on b.building_pk = m.building_fk
        left join view_os_v1 osc on osc.os_pk = d.os_fk
        left join view_vendor_v1 v2 on osc.vendor_fk = v2.vendor_pk
        left join view_device_custom_fields_flat_v1 dcf on dcf.device_fk = d.device_pk
        left join view_cloudinstance_v1 ci on ci.device_fk = d.device_pk
        left join view_vendor_v1 cv on cv.vendor_pk = ci.vendor_fk
        left join view_customer_v1 cu on cu.customer_pk = d.customer_fk
        order by d.name ASC