import os
from django.views.generic import TemplateView
from django.views.decorators.cache import never_cache
from django.utils.decorators import method_decorator
from django.conf import settings

@method_decorator(never_cache, name='dispatch')
class FrontendAppView(TemplateView):
    def get_template_names(self):
        return [os.path.join(settings.BASE_DIR, 'frontend', 'dist', 'index.html')]
