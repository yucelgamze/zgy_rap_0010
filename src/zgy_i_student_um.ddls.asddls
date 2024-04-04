@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Semester Interface View Unmanaged'
define root view entity zgy_i_student_um
  as select from zgy_student_um
  association [1..*] to zgy_i_gender_um  as _gender on $projection.Gender = _gender.value
  association [1..*] to zgy_i_course_um  as _course on $projection.Course = _course.Value
  composition [0..*] of zgy_i_results_um as _results
{
  key id                  as Id,
      studentid           as Studentid,
      firstname           as Firstname,
      lastname            as Lastname,
      studentage          as Studentage,
      course              as Course,
      courseduration      as Courseduration,
      studentstatus       as Studentstatus,
      gender              as Gender,
      dob                 as Dob,
      lastchangedat       as Lastchangedat,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true // Etag field olduğunu framework anlasın diye eklenen annotation
      locallastchangedat  as Locallastchangedat,
      _gender.Description as Genderdesc,
      _gender,
      _course.Description as Coursedesc,
      _course,
      _results
}
