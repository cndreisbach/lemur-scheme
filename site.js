var displayCommits = function (response) {
  var commits = response.commits;
  $('#commits').append("<h2>Recent Commits</h2>");
  for (var i = 0; i < Math.min(3, commits.length); i++) {
    $('#commits').append(
      "<p><a href='" + commits[i].url + "'>" + commits[i].message + "</a></p>");
  }
};
