subroutine UPBE_gga_correlation_potential(nGrid,weight,nBas,AO,dAO,rho,drho,Fc)

! Compute LYP correlation potential

  implicit none
  include 'parameters.h'

! Input variables

  integer,intent(in)            :: nGrid
  double precision,intent(in)   :: weight(nGrid)
  integer,intent(in)            :: nBas
  double precision,intent(in)   :: AO(nBas,nGrid)
  double precision,intent(in)   :: dAO(ncart,nBas,nGrid)
  double precision,intent(in)   :: rho(nGrid,nspin)
  double precision,intent(in)   :: drho(ncart,nGrid,nspin)

! Local variables

  integer                       :: mu,nu,iG
  double precision              :: vAO,gaAO,gbAO
  double precision              :: ra,rb,r
  double precision              :: ga,gab,gb,g
  double precision              :: dfdra,dfdrb
  double precision              :: dfdga,dfdgab,dfdgb
  double precision              :: dodra,dodrb,dddra,dddrb

  double precision              :: a,b,c,d
  double precision              :: Cf,omega,delta

! Output variables

  double precision,intent(out)  :: Fc(nBas,nBas,nspin)

! Prameter of the functional

! Compute matrix elements in the AO basis

  call UPW92_lda_correlation_potential(nGrid,weight,nBas,AO,rho,Fc)

  do mu=1,nBas
    do nu=1,nBas
      do iG=1,nGrid

        ra = max(0d0,rho(iG,1))
        rb = max(0d0,rho(iG,2))
        r  = ra + rb
 
        if(r > threshold) then

          ga  = drho(1,iG,1)*drho(1,iG,1) + drho(2,iG,1)*drho(2,iG,1) + drho(3,iG,1)*drho(3,iG,1)
          gb  = drho(1,iG,2)*drho(1,iG,2) + drho(2,iG,2)*drho(2,iG,2) + drho(3,iG,2)*drho(3,iG,2)
          gab = drho(1,iG,1)*drho(1,iG,2) + drho(2,iG,1)*drho(2,iG,2) + drho(3,iG,1)*drho(3,iG,2)
          g   = ga + 2d0*gab + gb

          vAO = weight(iG)*AO(mu,iG)*AO(nu,iG)

          dfdra = 0d0
          dfdrb = 0d0

          Fc(mu,nu,1) = Fc(mu,nu,1) + vAO*dfdra
          Fc(mu,nu,2) = Fc(mu,nu,2) + vAO*dfdrb
          
          gaAO = drho(1,iG,1)*(dAO(1,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(1,nu,iG)) & 
               + drho(2,iG,1)*(dAO(2,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(2,nu,iG)) & 
               + drho(3,iG,1)*(dAO(3,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(3,nu,iG))
          gaAO = weight(iG)*gaAO

          gbAO = drho(1,iG,2)*(dAO(1,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(1,nu,iG)) & 
               + drho(2,iG,2)*(dAO(2,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(2,nu,iG)) & 
               + drho(3,iG,2)*(dAO(3,mu,iG)*AO(nu,iG) + AO(mu,iG)*dAO(3,nu,iG))
          gbAO = weight(iG)*gbAO

          dfdga  = 0d0
          dfdgab = 0d0
          dfdgb  = 0d0

          
          Fc(mu,nu,1) = Fc(mu,nu,1) + 2d0*gaAO*dfdga + gbAO*dfdgab
          Fc(mu,nu,2) = Fc(mu,nu,2) + 2d0*gbAO*dfdgb + gaAO*dfdgab

        end if

      end do
    end do
  end do

end subroutine UPBE_gga_correlation_potential
