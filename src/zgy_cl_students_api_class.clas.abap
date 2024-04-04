CLASS zgy_cl_students_api_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_create_student TYPE TABLE FOR CREATE zgy_i_student_um\\student,
      tt_mapped_early   TYPE RESPONSE FOR MAPPED EARLY zgy_i_student_um,
      tt_failed_early   TYPE RESPONSE FOR FAILED EARLY zgy_i_student_um,
      tt_reported_early TYPE RESPONSE FOR REPORTED EARLY zgy_i_student_um,
      tt_reported_late  TYPE RESPONSE FOR REPORTED LATE zgy_i_student_um,
      tt_read_import    TYPE TABLE FOR READ IMPORT zgy_i_student_um\\student,
      tt_read_result    TYPE TABLE FOR READ RESULT zgy_i_student_um\\student,
      tt_update_student TYPE TABLE FOR UPDATE zgy_i_student_um\\student,
      tt_cba_create     TYPE TABLE FOR CREATE zgy_i_student_um\\student\_results,
      tt_delete_student TYPE TABLE FOR DELETE zgy_i_student_um\\student.


    "constructor
    CLASS-METHODS:    get_instance RETURNING VALUE(ro_instance) TYPE REF TO zgy_cl_students_api_class.

    DATA:gt_students   TYPE TABLE OF zgy_student_um.

    METHODS:
      earlynumbering_create_student
        IMPORTING entities TYPE tt_create_student "table for CREATE zgy_i_student_um\\student
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zgy_i_student_um
                  failed   TYPE tt_failed_early "response for failed early zgy_i_student_um
                  reported TYPE tt_reported_early, "response for reported early zgy_i_student_um

      create_student
        IMPORTING entities TYPE tt_create_student "table for create zgy_i_student_um\\student
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zgy_i_student_um
                  failed   TYPE tt_failed_early "response for failed early zgy_i_student_um
                  reported TYPE tt_reported_early ,"response for reported early zgy_i_student_um
      get_next_id
        RETURNING
          VALUE(rv_id) TYPE sysuuid_x16,

      get_next_student_id
        RETURNING
          VALUE(rv_studentid) TYPE zgy_de_student_id_um,

      savedata
        CHANGING reported TYPE tt_reported_late, "response for reported late zgy_i_student_um

      read_student
        IMPORTING keys     TYPE tt_read_import "table for read import zgy_i_student_um\\student
        CHANGING  result   TYPE tt_read_result "table for read result zgy_i_student_um\\student
                  failed   TYPE tt_failed_early "response for failed early zgy_i_student_um
                  reported TYPE tt_reported_early,"response for reported early zgy_i_student_um

      update_student
        IMPORTING entities TYPE tt_update_student "table for update zgy_i_student_um\\student
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zgy_i_student_um
                  failed   TYPE tt_failed_early "response for failed early zgy_i_student_um
                  reported TYPE tt_reported_early, "response for reported early zgy_i_student_um

      earlynumbering_cba_results
        IMPORTING entities TYPE tt_cba_create "table for create zgy_i_student_um\\student\_results
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zgy_i_student_um
                  failed   TYPE tt_failed_early "response for failed early zgy_i_student_um
                  reported TYPE tt_reported_early ,"response for reported early zgy_i_student_um

      cba_results
        IMPORTING entities_cba TYPE tt_cba_create "table for create zgy_i_student_um\\student\_results
        CHANGING  mapped       TYPE tt_mapped_early "response for mapped early zgy_i_student_um
                  failed       TYPE tt_failed_early "response for failed early zgy_i_student_um
                  reported     TYPE tt_reported_early, "response for reported early zgy_i_student_um

      delete_student
        IMPORTING keys     TYPE tt_delete_student "table for DELETE zgy_i_student_um\\student
        CHANGING  mapped   TYPE tt_mapped_early "response for mapped early zgy_i_student_um
                  failed   TYPE tt_failed_early "response for failed early zgy_i_student_um
                  reported TYPE tt_reported_early. "response for reported early zgy_i_student_um


  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA:mo_intance    TYPE REF TO zgy_cl_students_api_class,
               gt_results    TYPE TABLE OF zgy_results_um,
               gs_mapped     TYPE tt_mapped_early,
               lv_timestampl TYPE timestampl,
               gr_student_id TYPE RANGE OF zgy_student_um-id.
ENDCLASS.


CLASS zgy_cl_students_api_class IMPLEMENTATION.

  METHOD get_instance.

    mo_intance = ro_instance = COND #( WHEN mo_intance IS BOUND
                                       THEN mo_intance
                                       ELSE NEW #(  ) ).

  ENDMETHOD.

  METHOD earlynumbering_create_student.

    DATA(ls_mapped) = gs_mapped.

    "DATA(lv_new_id) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
    DATA(lv_new_id) = get_next_id(  ).

    "Buffer Table Update
    READ TABLE gt_students ASSIGNING FIELD-SYMBOL(<lfs_student>) INDEX 1.
    IF <lfs_student> IS ASSIGNED.
      <lfs_student>-id = lv_new_id.
      UNASSIGN <lfs_student>.
    ENDIF.

    "frontend e backend verisi aktarılması
    mapped-student = VALUE #(
    FOR ls_entities IN entities WHERE ( id IS INITIAL )
    (
        %cid      = ls_entities-%cid
        %is_draft = ls_entities-%is_draft
        Id        = lv_new_id
    )
     ).
  ENDMETHOD.

  METHOD create_student.

*    gt_students = CORRESPONDING #( entities MAPPING FROM ENTITY ).

*    IF gt_students[] IS NOT INITIAL.
*      gt_students[ 1 ]-studentid = get_next_student_id( ).
*    ENDIF.
*    mapped = VALUE #(
*    student = VALUE #(
*    FOR ls_entity IN entities (
*           %cid      = ls_entity-%cid
*           %is_draft = ls_entity-%is_draft
*           %key      = ls_entity-%key
*    ) ) ).

    gt_students = CORRESPONDING #( entities MAPPING FROM ENTITY ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>).
      IF gt_students[] IS NOT INITIAL.
        gt_students[ 1 ]-studentid = get_next_student_id( ).

        GET TIME STAMP FIELD lv_timestampl.
        gt_students[ 1 ]-locallastchangedat = lv_timestampl.
        gt_students[ 1 ]-lastchangedat      = lv_timestampl.

        mapped-student = VALUE #( (
                     %cid      = <lfs_entities>-%cid
                     %is_draft = <lfs_entities>-%is_draft
                     %key      = <lfs_entities>-%key   ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_next_id.
    TRY.
        rv_id = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.
  ENDMETHOD.

  METHOD get_next_student_id.

    SELECT MAX( studentid ) FROM zgy_student_um INTO @DATA(lv_max_studentid).
    rv_studentid = lv_max_studentid + 1.

  ENDMETHOD.

  METHOD savedata.

    IF gt_students[] IS NOT INITIAL.
      MODIFY zgy_student_um FROM TABLE @gt_students.
    ENDIF.

    IF gt_results[] IS NOT INITIAL.
      MODIFY zgy_results_um FROM TABLE @gt_results.
    ENDIF.

    IF gr_student_id IS NOT INITIAL.
      DELETE FROM zgy_student_um WHERE id IN @gr_student_id.
    ENDIF.

  ENDMETHOD.

  METHOD read_student.

    SELECT * FROM zgy_student_um FOR ALL ENTRIES IN @keys
    WHERE id = @keys-Id
    INTO TABLE @DATA(lt_read_student).

    result = CORRESPONDING #( lt_read_student MAPPING TO ENTITY ).

  ENDMETHOD.

  METHOD update_student.

    DATA:lt_update_student   TYPE TABLE OF zgy_student_um,
         lt_update_student_x TYPE TABLE OF zgy_cs_student_prop_um.

    lt_update_student   = CORRESPONDING #( entities MAPPING FROM ENTITY ).
    lt_update_student_x = CORRESPONDING #( entities MAPPING FROM ENTITY USING CONTROL ).

    GET TIME STAMP FIELD lv_timestampl.

    IF lt_update_student IS NOT INITIAL.

      SELECT * FROM zgy_student_um
      FOR ALL ENTRIES IN @lt_update_student
      WHERE id = @lt_update_student-id
      INTO TABLE @DATA(lt_old_update_student).

    ENDIF.

    gt_students = VALUE #(

    FOR x = 1 WHILE x <= lines( lt_update_student )

    LET
        ls_control_flag = VALUE #( lt_update_student_x[ x ] OPTIONAL )
        ls_new_student  = VALUE #( lt_update_student[ x ] OPTIONAL )
        ls_old_student  = VALUE #( lt_old_update_student[ id = ls_new_student-id ] OPTIONAL )
    IN
    (
        id             = ls_new_student-id
        studentid      = COND #( WHEN ls_control_flag-studentid      IS NOT INITIAL THEN ls_new_student-studentid      ELSE ls_old_student-studentid )
        firstname      = COND #( WHEN ls_control_flag-firstname      IS NOT INITIAL THEN ls_new_student-firstname      ELSE ls_old_student-firstname )
        lastname       = COND #( WHEN ls_control_flag-lastname       IS NOT INITIAL THEN ls_new_student-lastname       ELSE ls_old_student-lastname )
        studentage     = COND #( WHEN ls_control_flag-studentage     IS NOT INITIAL THEN ls_new_student-studentage     ELSE ls_old_student-studentage  )
        course         = COND #( WHEN ls_control_flag-course         IS NOT INITIAL THEN ls_new_student-course         ELSE ls_old_student-course )
        courseduration = COND #( WHEN ls_control_flag-courseduration IS NOT INITIAL THEN ls_new_student-courseduration ELSE ls_old_student-courseduration )
        studentstatus  = COND #( WHEN ls_control_flag-studentstatus  IS NOT INITIAL THEN ls_new_student-studentstatus  ELSE ls_old_student-studentstatus )
        gender         = COND #( WHEN ls_control_flag-gender         IS NOT INITIAL THEN ls_new_student-gender         ELSE ls_old_student-gender )
        dob            = COND #( WHEN ls_control_flag-dob            IS NOT INITIAL THEN ls_new_student-dob            ELSE ls_old_student-dob )
        locallastchangedat = lv_timestampl
        lastchangedat      = lv_timestampl
    )
    ).
  ENDMETHOD.

  METHOD earlynumbering_cba_results.

    DATA(lv_new_result_id) = get_next_id( ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>).

      LOOP AT <lfs_entities>-%target ASSIGNING FIELD-SYMBOL(<lfs_result_create>).
        mapped-results = VALUE #( (
                       %cid      = <lfs_result_create>-%cid
                       %is_draft = <lfs_result_create>-%is_draft
                       %key      = <lfs_result_create>-%key   ) ).
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD cba_results.

    gt_results = VALUE #(

    FOR ls_entities IN entities_cba
        FOR ls_results_cba IN ls_entities-%target
            LET
               ls_rap_results = CORRESPONDING zgy_results_um( ls_results_cba MAPPING FROM ENTITY )
            IN
              ( ls_rap_results )
    ).

    mapped = VALUE #(
        results = VALUE #(
        FOR i = 1 WHILE i <= lines( entities_cba )
        LET
           lt_results = VALUE #( entities_cba[ i ]-%target OPTIONAL )
        IN
           FOR j = 1 WHILE j <= lines( lt_results )
           LET
              ls_curr_resutls = VALUE #( lt_results[ j ] OPTIONAL )
           IN
           (
             %cid = ls_curr_resutls-%cid
             %key = ls_curr_resutls-%key
             Id   = ls_curr_resutls-Id
           )
        )
    ).

  ENDMETHOD.

  METHOD delete_student.

    DATA:lt_student TYPE STANDARD TABLE OF zgy_student_um.

    lt_student = CORRESPONDING #( keys MAPPING FROM ENTITY ).

    gr_student_id = VALUE #(
        FOR ls_student_id IN lt_student
            sign = 'I'
            option = 'EQ'
            ( low = ls_student_id-id )
    ).
  ENDMETHOD.

ENDCLASS.
