{
  # Allows pulling out specific resources from an object stream for further modification
  findResource: function(list,name=null,apiVersion=null,kind=null){
    local matchfun = function(resource)(
      ( name == null || resource.metadata.name == name)
      && ( apiVersion == null || resource.apiVersion == apiVersion)
      && ( kind == null || resource.kind == kind)
    ),
    match: std.filter(matchfun,list),
    rest: std.filter(function(resource) !matchfun(resource),list),
  }
}
