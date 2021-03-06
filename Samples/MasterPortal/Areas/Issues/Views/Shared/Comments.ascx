<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<Site.Areas.Issues.ViewModels.IssueCommentsViewModel>" %>
<%@ Import Namespace="Adxstudio.Xrm.Resources" %> 
<%@ Import Namespace="Adxstudio.Xrm.Web.Mvc.Html" %>
<%@ Import Namespace="Site.Helpers" %>

<% if (Model.Issue.CommentCount > 0) { %>
	<legend><%: Html.SnippetLiteral("Issue Comments Label", ResourceManager.GetString("Comments"))%> (<%: Model.Issue.CommentCount %>)</legend>
	<ul class="list-unstyled">
		<% foreach (var comment in Model.Comments) { %>
			<li>
				<div class="row comment">
					<div class="col-sm-3 comment-metadata">
						<div class="comment-author">
							<% if (comment.Author.EntityReference != null) { %>
								<a href="<%= Url.AuthorUrl(comment) %>"><%= comment.Author.DisplayName%></a>
							<% } else { %>
								<%: comment.Author.DisplayName%>
							<% } %>
						</div>
						<abbr class="timeago"><%: comment.Date.ToString("r") %></abbr>
					</div>
					<div class="col-sm-9 comment-content">
						<%= comment.Content %>
					</div>
				</div>
			</li>
		<% } %>
	</ul>
	<% Html.RenderPartial("Pagination", Model.Comments); %>
<% } 
if (Model.Issue.CurrentUserCanComment) { %>
	<% using (Html.BeginForm("CommentCreate", "Issue", new { id = Model.Issue.Id }, FormMethod.Post, new { id="create-comment", @class = "form-horizontal html-editors" } )) { %>
		<fieldset>
			<legend><%: Html.SnippetLiteral("Add Comment Label", ResourceManager.GetString("Add_A_Comment"))%></legend>
			<%= Html.ValidationSummary(string.Empty, new {@class = "alert alert-block alert-danger"})%>
			<% if (!Request.IsAuthenticated) { %>
				<div class="form-group">
					<label class="col-sm-3 control-label required" for="authorName">Your Name</label>
					<div class="col-sm-9">
						<%= Html.TextBox("authorName", string.Empty, new { @class = "form-control" })%>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-3 control-label required" for="authorEmail">E-mail</label>
					<div class="col-sm-9">
						<%= Html.TextBox("authorEmail", string.Empty, new { @class = "form-control" })%>
					</div>
				</div>
			<% } %>
			<div class="form-group">
				<label class="col-sm-3 control-label required" for="title">Comment</label>
				<div class="col-sm-9">
					<%= Html.TextArea("copy", string.Empty, new { @class = "form-control" })%>
				</div>
			</div>
			<div class="form-group">
				<div class="col-sm-offset-3 col-sm-9">
					<input id="post-comment" class="btn btn-primary" type="submit" value="<%: Html.SnippetLiteral("Post Comment Label", ResourceManager.GetString("Post_Comment"))%>" />
				</div>
			</div>
		</fieldset>
	<% }
} %>
<script type="text/javascript">
	$(function () {
		$("#post-comment").click(function () {
		    $.blockUI({ message: null, overlayCSS: { opacity: .3 } });

		    shell.ajaxSafePost({
		        type: "POST",
		        success: function (result) {
		            $("#comments").html(result);
		            commentCreated();
		        }
		    }, $("#create-comment"));

		    return false;
		});
	});

	function commentCreated() {
		portal.convertAbbrDateTimesToTimeAgo($);

		if ($("#create-comment .validation-summary-errors").length == 0) {
			$("#create-comment :input").each(function () {
				if (this.type == "text" || this.tagName.toLowerCase() == "textarea") {
					this.value = "";
				}
			});
		}

		prettyPrint();

		portal.initializeHtmlEditors();

		$.unblockUI();
	}
</script>
