@EndUserText.label : 'Cognitus University Registration Details'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table zcuregist {
  @AbapCatalog.foreignKey.label : 'Class Name'
  @AbapCatalog.foreignKey.keyType : #KEY
  @AbapCatalog.foreignKey.screenCheck : true
  key classes       : char40 not null
    with foreign key [1,1] zcoguniclass
      where client = syst.mandt
        and name = zcuregist.classes
        and class_section = zcuregist.class_section;
  @AbapCatalog.foreignKey.screenCheck : true
  key class_section : char3 not null
    with foreign key zcoguniclass
      where client = syst.mandt
        and name = zcuregist.classes
        and class_section = zcuregist.class_section;
  @AbapCatalog.foreignKey.keyType : #KEY
  @AbapCatalog.foreignKey.screenCheck : true
  key student_num   : char9 not null
    with foreign key [1..*,1] zcogunistudents
      where student_num = zcuregist.student_num;

}
