BEGIN
   pkg_load_dw_kinder.load_dw_kinder;
   pkg_load_dw_kinder.load_dw_groups;
   pkg_load_dw_kinder.load_dw_kinder_link;
   pkg_load_dw_emp.load_dw_emp ;
   pkg_load_dw_serv.load_dw_serv;
   pkg_load_dw_serv.load_dw_types;
   pkg_load_dw_serv.load_dw_serv_scd;
   pkg_load_dw_child.load_dw_child;
END;