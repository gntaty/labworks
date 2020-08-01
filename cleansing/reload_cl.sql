BEGIN
   pkg_etl_ls_attendances.load_ls_attendances;
  pkg_etl_ls_children.load_ls_children;
  pkg_etl_ls_emp.load_ls_employees;
   pkg_etl_ls_serv.load_ls_services;
   pkg_etl_ls_kinder.load_ls_kinder;
END;