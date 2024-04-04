@EndUserText.label: 'Student Consumption View Unmanaged'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity zgy_c_student_um
  provider contract transactional_query
  as projection on zgy_i_student_um
{ @EndUserText.label: 'ID'
  key Id,
  @EndUserText.label: 'Student ID'
      Studentid,
      @EndUserText.label: 'First Name'
      Firstname,
      @EndUserText.label: 'Last Name'
      Lastname,
       @EndUserText.label: 'Student Age'
      Studentage,
       @EndUserText.label: 'Course'
      Course,
      Coursedesc,
      @EndUserText.label: 'Course Duration'
      Courseduration,
       @EndUserText.label: 'Student Status'
      Studentstatus,
       @EndUserText.label: 'Gender'
      Gender,
      Genderdesc,
      @EndUserText.label: 'Date of Birth'
      Dob,
//      Lastchangedat,
      Locallastchangedat, // Etag alanı eklendi
      
      /* Associations */
      _gender,
      _course,
      _results: redirected to composition child zgy_c_results_um
}
