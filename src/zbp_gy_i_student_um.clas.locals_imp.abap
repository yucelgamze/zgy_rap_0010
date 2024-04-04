CLASS lhc_Student DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Student RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Student RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Student.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Student.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Student.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Student.

    METHODS read FOR READ
      IMPORTING keys FOR READ Student RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Student.

    METHODS rba_Results FOR READ
      IMPORTING keys_rba FOR READ Student\_Results FULL result_requested RESULT result LINK association_links.

    METHODS cba_Results FOR MODIFY
      IMPORTING entities_cba FOR CREATE Student\_Results.
    METHODS validate_fields FOR VALIDATE ON SAVE
      IMPORTING keys FOR Student~validate_fields.
    METHODS updateCourseDuration FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Student~updateCourseDuration.
    METHODS updateStudentStatus FOR MODIFY
      IMPORTING keys FOR ACTION Student~updateStudentStatus RESULT result.

    METHODS earlynumbering_cba_Results FOR NUMBERING
      IMPORTING entities FOR CREATE Student\_Results.

ENDCLASS.

CLASS lhc_Student IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    zgy_cl_students_api_class=>get_instance( )->create_student(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD earlynumbering_create.

    zgy_cl_students_api_class=>get_instance( )->earlynumbering_create_student(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD update.

    zgy_cl_students_api_class=>get_instance( )->update_student(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD delete.
    zgy_cl_students_api_class=>get_instance( )->delete_student(
      EXPORTING
        keys     = keys
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD read.

    zgy_cl_students_api_class=>get_instance( )->read_student(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD lock.

    TRY.
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZGYLOCKSTUDENT' ).
      CATCH cx_abap_lock_failure INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_student>).

      TRY.
          lock->enqueue(
            it_parameter  = VALUE #( ( name = 'ID' value = REF #( <lfs_student>-Id ) ) )
          ).

        CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
          APPEND VALUE #(
          id   = keys[ 1 ]-Id
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Kayıt { foreign_lock->user_name } kullanıcı tarafından kitlendi.|
                 )
          ) TO reported-student.

          APPEND VALUE #(
          id   = keys[ 1 ]-Id
          ) TO failed-student.

        CATCH cx_abap_lock_failure INTO exception.
          RAISE SHORTDUMP exception.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD rba_Results.
  ENDMETHOD.

  METHOD cba_Results.

    zgy_cl_students_api_class=>get_instance( )->cba_results(
      EXPORTING
        entities_cba = entities_cba
      CHANGING
        mapped       = mapped
        failed       = failed
        reported     = reported
    ).

  ENDMETHOD.

  METHOD earlynumbering_cba_Results.

    zgy_cl_students_api_class=>get_instance( )->earlynumbering_cba_results(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD validate_fields.
    READ ENTITIES OF zgy_i_student_um
    IN LOCAL MODE
    ENTITY Student
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_student_tmp)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    IF lt_student_tmp[] IS NOT INITIAL.
      READ TABLE lt_student_tmp ASSIGNING FIELD-SYMBOL(<lfs_student_tmp>) INDEX 1.
      IF <lfs_student_tmp> IS ASSIGNED.

        "entity i clear etmek için -----------------------
        reported-student = VALUE #(
                                    ( %tky = <lfs_student_tmp>-%tky  %state_area = |VALIDATE_FIRSTNAME| )
                                    ( %tky = <lfs_student_tmp>-%tky  %state_area = |VALIDATE_LASTNAME| )
                                    ( %tky = <lfs_student_tmp>-%tky  %state_area = |VALIDATE_AGE| ) ).
        "entity i clear etmek için -----------------------
        IF <lfs_student_tmp>-Firstname IS INITIAL OR
           <lfs_student_tmp>-Lastname IS INITIAL OR
           <lfs_student_tmp>-Studentage IS INITIAL.

          failed-student = VALUE #( ( %tky = <lfs_student_tmp>-%tky ) ).

          IF <lfs_student_tmp>-Firstname IS INITIAL.
            reported-student = VALUE #( ( %tky               = <lfs_student_tmp>-%tky
                                          %state_area        = |VALIDATE_FIRSTNAME|  "alan kutusu altında kırmızı uyarı
                                          %element-firstname = if_abap_behv=>mk-on
                                          %msg     = new_message(
                                                       id       = 'SY'
                                                       number   = '002'
                                                       severity = if_abap_behv_message=>severity-error
                                                       v1       = |Firstname alanı gereklidir!|  ) ) ).
          ENDIF.

          IF <lfs_student_tmp>-Lastname IS INITIAL.
            reported-student = VALUE #( BASE reported-student ( %tky              = <lfs_student_tmp>-%tky
                                          %state_area       = |VALIDATE_LASTNAME|
                                          %element-lastname = if_abap_behv=>mk-on
                                          %msg     = new_message(
                                                       id       = 'SY'
                                                       number   = '002'
                                                       severity = if_abap_behv_message=>severity-error
                                                       v1       = |Lastname alanı gereklidir!|  )  ) ).
          ENDIF.

          IF <lfs_student_tmp>-Studentage IS INITIAL.
            reported-student = VALUE #( BASE reported-student ( %tky                = <lfs_student_tmp>-%tky
                                          %state_area         = |VALIDATE_AGE|
                                          %element-studentage = if_abap_behv=>mk-on
                                          %msg     = new_message(
                                                       id       = 'SY'
                                                       number   = '002'
                                                       severity = if_abap_behv_message=>severity-error
                                                       v1       = |Studentage alanı gereklidir!|  ) ) ).
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD updateCourseDuration.

    READ ENTITIES OF zgy_i_student_um
    IN LOCAL MODE
    ENTITY Student
    FIELDS ( Course ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_student_course)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    LOOP AT lt_student_course ASSIGNING FIELD-SYMBOL(<lfs_student_course>).

      IF <lfs_student_course>-Course = |C|.
        MODIFY ENTITIES OF zgy_i_student_um
        IN LOCAL MODE
        ENTITY Student
        UPDATE FIELDS ( Courseduration )
        WITH VALUE #( ( %tky = <lfs_student_course>-%tky Courseduration = 9 ) ).
      ENDIF.

      IF <lfs_student_course>-Course = |E|.
        MODIFY ENTITIES OF zgy_i_student_um
        IN LOCAL MODE
        ENTITY Student
        UPDATE FIELDS ( Courseduration )
        WITH VALUE #( ( %tky = <lfs_student_course>-%tky Courseduration = 6 ) ).
      ENDIF.

      IF <lfs_student_course>-Course = |M|.
        MODIFY ENTITIES OF zgy_i_student_um
        IN LOCAL MODE
        ENTITY Student
        UPDATE FIELDS ( Courseduration )
        WITH VALUE #( ( %tky = <lfs_student_course>-%tky Courseduration = 3 ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD updateStudentStatus.

    DATA(lt_keys) = keys.

    READ ENTITIES OF zgy_i_student_um
    IN LOCAL MODE
    ENTITY Student
    FIELDS ( Studentstatus ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_student_cs).

    DATA(lv_new_status) = lt_keys[ 1 ]-%param-studentstatus.

    MODIFY ENTITIES OF zgy_i_student_um
    IN LOCAL MODE
    ENTITY Student
    UPDATE FIELDS ( Studentstatus )
    WITH VALUE #( ( %tky = lt_student_cs[ 1 ]-%tky Studentstatus = lv_new_status ) ).

    READ ENTITIES OF zgy_i_student_um
    IN LOCAL MODE
    ENTITY Student
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_student).

    result = VALUE #( FOR <lfs_student> IN lt_student ( %tky   = <lfs_student>-%tky
                                                        %param = <lfs_student> ) ).

  ENDMETHOD.


ENDCLASS.

CLASS lhc_Results DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Results.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Results.

    METHODS read FOR READ
      IMPORTING keys FOR READ Results RESULT result.

    METHODS rba_Student FOR READ
      IMPORTING keys_rba FOR READ Results\_Student FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Results IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Student.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZGY_I_STUDENT_UM DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZGY_I_STUDENT_UM IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.

    DATA:gt_students_tmp   TYPE TABLE OF zgy_student_um.
    gt_students_tmp = zgy_cl_students_api_class=>get_instance( )->gt_students.

    IF gt_students_tmp[] IS NOT INITIAL.
      READ TABLE gt_students_tmp ASSIGNING FIELD-SYMBOL(<lfs_students_tmp>) INDEX 1.
      IF <lfs_students_tmp> IS ASSIGNED.
        IF <lfs_students_tmp>-studentage < 16.
          APPEND VALUE #( id = <lfs_students_tmp>-id ) TO failed-student.

          APPEND VALUE #( id   = <lfs_students_tmp>-id
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = |Yaş 16 dan küçük olamaz!|
                                 ) ) TO reported-student.
        ENDIF.

        IF <lfs_students_tmp>-studentstatus EQ abap_false.
          APPEND VALUE #( id = <lfs_students_tmp>-id ) TO failed-student.

          APPEND VALUE #( id   = <lfs_students_tmp>-id
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = |Statü aktif olamalıdır!|
                                 ) ) TO reported-student.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD save.

    zgy_cl_students_api_class=>get_instance( )->savedata(
      CHANGING
        reported = reported
    ).

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
