@EndUserText.label: 'Results Consumption View Unmanaged'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity zgy_c_results_um
  as projection on zgy_i_results_um
{
      @EndUserText.label: 'Student ID'
  key Id,
      @EndUserText.label: 'Course'
      Course,
      @EndUserText.label: 'Semester'
      Semester,
      @EndUserText.label: 'Course Description'
      course_desc,
      @EndUserText.label: 'Semester Description'
      semester_desc,
      @EndUserText.label: 'Semester Result'
      Semresult,
      @EndUserText.label: 'Semester Result Description'
      semres_desc,
      /* Associations */
      _student : redirected to parent zgy_c_student_um
}
