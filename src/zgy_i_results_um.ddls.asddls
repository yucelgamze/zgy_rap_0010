@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Results Interface View Unmanaged'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zgy_i_results_um
  as select from zgy_results_um
  association to parent zgy_i_student_um as _student on $projection.Id = _student.Id
  association to zgy_i_course_um         as _course  on $projection.Course = _course.Value
  association to zgy_i_semester_um       as _sem     on $projection.Semester = _sem.Value
  association to zgy_i_sresult_um        as _semres  on $projection.Semresult = _semres.Value
{
      @EndUserText.label: 'Student ID'
  key zgy_results_um.id        as Id,
      @EndUserText.label: 'Course'
      zgy_results_um.course    as Course,
      @EndUserText.label: 'Semester'
      zgy_results_um.semester  as Semester,
      @EndUserText.label: 'Course Description'
      _course.Description      as course_desc,
      @EndUserText.label: 'Semester Description'
      _sem.text                as semester_desc,
      @EndUserText.label: 'Semester Result'
      zgy_results_um.semresult as Semresult,
      @EndUserText.label: 'Semester Result Description'
      _semres.text             as semres_desc,
      _student
}
